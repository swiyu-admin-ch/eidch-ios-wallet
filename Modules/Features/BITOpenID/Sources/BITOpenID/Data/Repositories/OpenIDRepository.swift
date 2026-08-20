import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITNetworking
import BITSdJWT
import BITVault
import Factory
import Foundation
import Moya
import Security

// MARK: - OpenIDRepository

struct OpenIDRepository: OpenIDRepositoryProtocol {

  // MARK: Internal

  func fetchVcSchemaData(from url: URL) async throws -> VcSchema {
    try await networkService.request(OpenIDEndpoint.vcSchema(url: url)).data
  }

  /// Retrieving Type Metadata from a registry given as the url parameter
  /// - Documentation: [SD-JWT-based Verifiable Credentials - Draft 06](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-06.html#name-from-a-registry)
  func fetchTypeMetadata(from url: URL) async throws -> (object: TypeMetadata, response: Response) {
    try await networkService.request(OpenIDEndpoint.typeMetadata(url: url))
  }

  func fetchMetadata(from issuerUrl: URL) async throws -> JWS<CredentialIssuerMetadataJWT> {
    do {
      let response = try await networkService.request(OpenIDEndpoint.metadata(fromIssuerUrl: issuerUrl))
      return try await parseMetadataResponse(response, from: issuerUrl)
    } catch is NetworkError {
      let response = try await networkService.request(OpenIDEndpoint.oidConnectMetadata(fromIssuerUrl: issuerUrl))
      return try await parseMetadataResponse(response, from: issuerUrl)
    }
  }

  func fetchOpenIdConfiguration(from issuerUrl: URL) async throws -> OpenIdConfiguration {
    do {
      let response = try await networkService.request(OpenIDEndpoint.openIdConfiguration(fromIssuerUrl: issuerUrl))
      return try await parseOpenIdConfigurationResponse(response, from: issuerUrl)
    } catch is NetworkError {
      let response = try await networkService.request(OpenIDEndpoint.oidConnectOpenIdConfiguration(fromIssuerUrl: issuerUrl))
      return try await parseOpenIdConfigurationResponse(response, from: issuerUrl)
    }
  }

  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo {
    try await networkService.request(OpenIDEndpoint.publicKeyInfo(jwksUrl: jwksUrl))
  }

  /// RFC 9449 Section 8 allows authorization servers to challenge with `use_dpop_nonce`
  /// and Section 8.2 allows returning the next nonce on a successful response.
  func fetchAccessToken(
    from url: URL,
    preAuthorizedCode: String,
    dpopKeyPair: VaultKeyPair?,
    dpopNonce: String?,
    dpopKeyAttestationJWS: String?) async throws
    -> IssuanceAuthorization
  {
    try await fetchTokenAuthorization(from: url, dpopKeyPair: dpopKeyPair, initialNonce: dpopNonce, keyAttestationJWS: dpopKeyAttestationJWS) { proof in
      OpenIDEndpoint.accessToken(fromTokenUrl: url, preAuthorizedCode: preAuthorizedCode, dpopProof: proof)
    }
  }

  func refreshAccessToken(
    from url: URL,
    refreshToken: String,
    dpopKeyPair: VaultKeyPair?,
    dpopNonce: String?) async throws
    -> IssuanceAuthorization
  {
    try await fetchTokenAuthorization(from: url, dpopKeyPair: dpopKeyPair, initialNonce: dpopNonce, keyAttestationJWS: nil) { proof in
      OpenIDEndpoint.refreshAccessToken(fromTokenUrl: url, refreshToken: refreshToken, dpopProof: proof)
    }
  }

  func fetchNonce(from url: URL) async throws -> (nonce: Nonce, dpopNonce: String?) {
    let (nonce, response): (Nonce, Response) = try await networkService.request(OpenIDEndpoint.nonce(url: url))
    return (nonce, response.response?.value(forHTTPHeaderField: Self.dpopNonceHeaderField))
  }

  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequest) async throws -> FetchAnyCredentialResult.Credentials {
    let jwe = try encryptCredentialRequest(credentialRequest, with: context.credentialEncryptionContext)
    let (response, authorization) = try await fetchProtectedResource(
      from: context.credentialEndpoint,
      authorization: context.authorization)
    { accessToken, dpopProof in
      OpenIDEndpoint.credential(
        url: context.credentialEndpoint,
        jwe: jwe,
        accessToken: accessToken,
        dpopProof: dpopProof)
    }

    return try await fetchCredential(
      response: response,
      authorization: authorization,
      format: context.format,
      privateKey: context.credentialEncryptionContext.responseKeyPair.privateKey,
      deferredCredentialEndpoint: context.deferredCredentialEndpoint)
  }

  func fetchCredential(with context: FetchDeferredCredentialContext, deferredCredentialRequest: DeferredCredentialRequest) async throws -> FetchAnyCredentialResult.Credentials {
    let jwe = try encryptCredentialRequest(deferredCredentialRequest, with: context.credentialEncryptionContext)
    let (response, authorization) = try await fetchProtectedResource(
      from: context.deferredCredentialEndpoint,
      authorization: context.authorization)
    { accessToken, dpopProof in
      OpenIDEndpoint.deferredCredential(
        url: context.deferredCredentialEndpoint,
        jwe: jwe,
        accessToken: accessToken,
        dpopProof: dpopProof)
    }

    return try await fetchCredential(
      response: response,
      authorization: authorization,
      format: context.format,
      privateKey: context.credentialEncryptionContext.responseKeyPair.privateKey,
      deferredCredentialEndpoint: context.deferredCredentialEndpoint)
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    let response = try await networkService.request(OpenIDEndpoint.status(url: url))
    return try jwsDecoder.decode(TokenStatusList.self, from: response.data)
  }

  // MARK: Private

  private static let dpopNonceHeaderField = "DPoP-Nonce"

  private let baseDPoPAdditionalHeaderParameters = ["profile_version": "swiss-profile-issuance:1.0.0"]

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.vcSdJwsDecoder) private var vcSdJwsDecoder: VcSdJWSDecoderProtocol
  @Injected(\NetworkContainer.decoder) private var jsonDecoder: JSONDecoder
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.jweEncrypter) private var jweEncrypter: JWEEncrypterProtocol
  @Injected(\.jweDecrypter) private var jweDecrypter: JWEDecrypterProtocol
  @Injected(\.dpopGenerator) private var dpopGenerator: DPoPGeneratorProtocol
  @Injected(\.isBatchIssuanceEnabled) private var isBatchIssuanceEnabled
  @Injected(\.oAuthErrorParser) private var oAuthErrorParser: OAuthErrorParserProtocol
  @Injected(\.openID4VCIErrorParser) private var openID4VCIErrorParser: OpenID4VCIErrorParserProtocol

  private func createDPoP(method: String, url: URL, keyPair: VaultKeyPair?, nonce: String?, accessToken: String?, keyAttestationJWS: String? = nil) throws -> DPoP? {
    guard let keyPair else {
      return nil
    }

    var additionalHeaderParameters = baseDPoPAdditionalHeaderParameters
    if let keyAttestationJWS {
      additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue] = keyAttestationJWS
    }

    return try dpopGenerator.generate(
      method: method,
      url: url,
      keyPair: keyPair,
      nonce: nonce,
      accessToken: accessToken,
      additionalHeaderParameters: additionalHeaderParameters)
  }

  /// Sends the token request and retries once if the authorization server challenges with
  /// RFC 9449 `error=use_dpop_nonce`.
  ///
  /// - Parameters:
  ///   - url: Token endpoint URL.
  ///   - dpopKeyPair: Key pair used to sign the DPoP proof, if DPoP is enabled.
  ///   - initialNonce: Optional nonce for the first proof, for example from the
  ///     OpenID4VCI 1.0 Section 7 `nonce_endpoint`.
  ///   - endpoint: Builds the concrete token request from the generated proof.
  /// - Returns: The issued authorization.
  private func fetchTokenAuthorization(
    from url: URL,
    dpopKeyPair: VaultKeyPair?,
    initialNonce: String?,
    keyAttestationJWS: String?,
    endpoint: (String?) -> OpenIDEndpoint) async throws
    -> IssuanceAuthorization
  {
    do {
      return try await requestTokenAuthorization(
        from: url,
        dpopKeyPair: dpopKeyPair,
        nonce: initialNonce,
        keyAttestationJWS: keyAttestationJWS,
        endpoint: endpoint)
    } catch {
      let parsedError = oAuthErrorParser.parse(error)
      guard case OpenIdRepositoryError.useDPoPNonce(_, let challengedNonce?) = parsedError else {
        throw parsedError
      }

      do {
        return try await requestTokenAuthorization(
          from: url,
          dpopKeyPair: dpopKeyPair,
          nonce: challengedNonce,
          keyAttestationJWS: keyAttestationJWS,
          endpoint: endpoint)
      } catch {
        throw oAuthErrorParser.parse(error)
      }
    }
  }

  private func encryptCredentialRequest(_ credentialRequest: Encodable, with context: CredentialEncryptionContext) throws -> String {
    let data = try JSONEncoder().encode(credentialRequest)
    return try jweEncrypter.encrypt(
      data: data,
      publicKey: context.issuerPublicKey,
      encryptionAlgorithm: context.credentialRequestEncryptionAlgorithm,
      compressionAlgorithm: context.credentialRequestEncryptionZipValue)
  }

  /// Sends the protected-resource request and retries once if the resource server
  /// challenges with RFC 9449 `use_dpop_nonce`.
  ///
  /// - Parameters:
  ///   - url: Protected-resource endpoint URL.
  ///   - authorization: Current authorization state, including access token, DPoP key
  ///     binding, and any proactive resource nonce from OpenID4VCI 1.0 Section 7
  ///     `nonce_endpoint`.
  ///   - endpoint: Builds the concrete protected-resource request from the access token
  ///     and generated proof.
  /// - Returns: The raw response together with updated authorization state.
  private func fetchProtectedResource(
    from url: URL,
    authorization: IssuanceAuthorization,
    endpoint: (AccessToken, String?) -> OpenIDEndpoint) async throws
    -> (response: Response, authorization: IssuanceAuthorization)
  {
    do {
      return try await requestProtectedResource(
        from: url,
        authorization: authorization,
        nonce: authorization.resourceServerDPoPNonce,
        endpoint: endpoint)
    } catch {
      let parsedError = openID4VCIErrorParser.parse(error)
      guard case OpenIdRepositoryError.useDPoPNonce(_, let challengedNonce?) = parsedError else {
        throw parsedError
      }

      do {
        return try await requestProtectedResource(
          from: url,
          authorization: authorization,
          nonce: challengedNonce,
          endpoint: endpoint)
      } catch {
        throw openID4VCIErrorParser.parse(error)
      }
    }
  }

  private func requestTokenAuthorization(
    from url: URL,
    dpopKeyPair: VaultKeyPair?,
    nonce: String?,
    keyAttestationJWS: String?,
    endpoint: (String?) -> OpenIDEndpoint) async throws
    -> IssuanceAuthorization
  {
    let dpopProof = try createDPoP(
      method: Moya.Method.post.rawValue.uppercased(),
      url: url,
      keyPair: dpopKeyPair,
      nonce: nonce,
      accessToken: nil,
      keyAttestationJWS: keyAttestationJWS)
    let accessToken: AccessToken = try await networkService.request(endpoint(dpopProof?.rawJWS))
    return IssuanceAuthorization(
      accessToken: accessToken,
      dpopKeyPair: dpopKeyPair)
  }

  private func requestProtectedResource(
    from url: URL,
    authorization: IssuanceAuthorization,
    nonce: String?,
    endpoint: (AccessToken, String?) -> OpenIDEndpoint) async throws
    -> (response: Response, authorization: IssuanceAuthorization)
  {
    let accessToken = authorization.accessToken
    let dpopProof = try createDPoP(
      method: Moya.Method.post.rawValue.uppercased(),
      url: url,
      keyPair: authorization.dpopKeyPair,
      nonce: nonce,
      accessToken: authorization.dpopKeyPair == nil ? nil : accessToken.accessToken)
    let response = try await networkService.request(endpoint(accessToken, dpopProof?.rawJWS))
    return (
      response,
      IssuanceAuthorization(
        accessToken: authorization.accessToken,
        dpopKeyPair: authorization.dpopKeyPair,
        resourceServerDPoPNonce: response.response?.value(forHTTPHeaderField: Self.dpopNonceHeaderField)))
  }

  private func parseMetadataResponse(_ response: Response, from endpoint: URL) async throws -> JWS<CredentialIssuerMetadataJWT> {
    let jws = try jwsDecoder.decode(CredentialIssuerMetadataJWT.self, from: response.data)
    try await jwsValidator.validate(jws)
    guard
      jws.payload.subject == endpoint.absoluteString,
      endpoint == jws.payload.credentialIssuerMetadata.credentialIssuer
    else {
      throw OpenIdRepositoryError.invalidCredentialIssuerMetadataJWT
    }
    return jws
  }

  private func parseOpenIdConfigurationResponse(_ response: Response, from endpoint: URL) async throws -> OpenIdConfiguration {
    let jws = try jwsDecoder.decode(OpenIdConfigurationJWT.self, from: response.data)
    try await jwsValidator.validate(jws)
    guard jws.payload.subject == endpoint.absoluteString else {
      throw OpenIdRepositoryError.invalidOpenIdConfigurationJWT
    }
    return jws.payload.openIdConfiguration
  }

  private func fetchCredential(
    response: Response,
    authorization: IssuanceAuthorization,
    format: CredentialFormat,
    privateKey: SecKey,
    deferredCredentialEndpoint: URL?) async throws
    -> FetchAnyCredentialResult.Credentials
  {
    do {
      guard ContentType(response.response) == .jwt else { throw OpenIdRepositoryError.unencryptedCredentialResponse }
      let decryptedPayload = try jweDecrypter.decrypt(payload: response.data, privateKey: privateKey)
      return try getAnyCredentialResult(
        from: response.statusCode,
        data: decryptedPayload,
        authorization: authorization,
        format: format,
        deferredCredentialEndpoint: deferredCredentialEndpoint)
    } catch {
      throw openID4VCIErrorParser.parse(error)
    }
  }

  private func getAnyCredentialResult(
    from statusCode: Int,
    data: Data,
    authorization: IssuanceAuthorization,
    format: CredentialFormat,
    deferredCredentialEndpoint: URL?) throws
    -> FetchAnyCredentialResult.Credentials
  {
    var credential: FetchAnyCredentialResult.Credentials

    if statusCode == 202 { // see RFC 9110 §15.3.3 for status codes
      let deferred = try JSONDecoder().decode(CredentialResponseDeferred.self, from: data)
      credential = try .deferred(getDeferredCredential(
        from: deferred,
        authorization: authorization,
        format: format,
        deferredCredentialEndpoint: deferredCredentialEndpoint))
    } else if statusCode == 200 {
      let immediate = try JSONDecoder().decode(CredentialResponseImmediate.self, from: data)
      let credentials = try getAnyCredentials(from: immediate.credentials)

      if !credentials.isEmpty {
        credential = .credential(credentials)
      } else {
        throw OpenIdRepositoryError.missingImmediateCredentialData
      }
    } else {
      throw OpenIdRepositoryError.unsupportedCredentialStatusCode
    }
    return credential
  }

  private func getDeferredCredential(
    from credentialResponse: CredentialResponseDeferred,
    authorization: IssuanceAuthorization,
    format: CredentialFormat,
    deferredCredentialEndpoint: URL?) throws
    -> DeferredCredentialContext
  {
    guard let endpoint = deferredCredentialEndpoint?.absoluteString else {
      throw OpenIdRepositoryError.missingDeferredCredentialEndpoint
    }

    return DeferredCredentialContext(
      transactionId: credentialResponse.transactionId,
      authorization: authorization,
      endpoint: endpoint,
      format: format,
      interval: credentialResponse.interval)
  }

  private func getAnyCredentials(from rawCredentials: [CredentialResponseImmediate.Credential]) throws -> [AnyCredential] {
    try rawCredentials.map { rawCredential in
      guard let credentialData = rawCredential.credential.data(using: .utf8) else {
        throw OpenIdRepositoryError.missingImmediateCredentialData
      }

      return try vcSdJwsDecoder.decode(VcSdJwt.self, from: credentialData)
    }
  }
}

// MARK: - OpenIdRepositoryError

public enum OpenIdRepositoryError: Error, Equatable {
  // OAuth 2.0
  case invalidRequest(String)
  case unauthorizedClient(String)
  case invalidScope(String)
  case invalidClient(String)
  case invalidGrant(String)
  case unsupportedGrantType(String)
  case invalidDPoPProof(String)
  case useDPoPNonce(String, String?)
  case invalidToken(String)
  case insufficientScope(String)
  case expiredAccessToken

  // credential request
  case invalidCredentialRequest(String)
  case unknownCredentialConfiguration(String)
  case unknownCredentialIdentifier(String)
  case invalidProof(String)
  case invalidNonce(String)
  case invalidEncryptionParameters(String)
  case credentialRequestDenied(String)
  case invalidTransactionId(String)

  case unsupportedCredentialStatusCode
  case invalidCredential
  case missingDeferredCredentialEndpoint
  case missingImmediateCredentialData
  case invalidCredentialIssuerMetadata
  case invalidCredentialIssuerMetadataJWT
  case invalidOpenIdConfigurationJWT
  case missingCredentialResponsePrivateKey
  case unencryptedCredentialResponse
}
