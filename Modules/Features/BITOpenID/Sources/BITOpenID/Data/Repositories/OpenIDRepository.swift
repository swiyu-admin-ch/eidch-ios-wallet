import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITNetworking
import BITSdJWT
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

  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialIssuerMetadataResponse {
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

  func fetchAccessToken(from url: URL, preAuthorizedCode: String) async throws -> AccessToken {
    do {
      return try await networkService.request(OpenIDEndpoint.accessToken(fromTokenUrl: url, preAuthorizedCode: preAuthorizedCode))
    } catch {
      throw oAuthErrorParser.parse(error)
    }
  }

  func refreshAccessToken(from url: URL, refreshToken: String) async throws -> AccessToken {
    do {
      return try await networkService.request(OpenIDEndpoint.refreshAccessToken(fromTokenUrl: url, refreshToken: refreshToken))
    } catch {
      throw oAuthErrorParser.parse(error)
    }
  }

  func fetchNonce(from url: URL) async throws -> Nonce {
    try await networkService.request(OpenIDEndpoint.nonce(url: url))
  }

  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequestBody) async throws -> FetchAnyCredentialResult.Credentials {
    let endpoint = OpenIDEndpoint.credential(
      url: context.credentialEndpoint,
      body: credentialRequest,
      accessToken: context.accessToken)

    return try await fetchCredential(
      endpoint: endpoint,
      accessToken: context.accessToken.accessToken,
      format: context.format,
      privateKey: context.credentialEncryptionContext?.responseKeyPair?.privateKey,
      deferredCredentialEndpoint: context.deferredCredentialEndpoint,
      refreshToken: context.accessToken.refreshToken)
  }

  func fetchCredential(with context: FetchDeferredCredentialContext, requestBody: DeferredCredentialRequestBody) async throws -> FetchAnyCredentialResult.Credentials {
    let endpoint = OpenIDEndpoint.deferredCredential(
      url: context.deferredCredentialEndpoint,
      body: requestBody,
      accessToken: context.accessToken)

    return try await fetchCredential(
      endpoint: endpoint,
      accessToken: context.accessToken,
      format: context.format,
      privateKey: context.privateKey,
      deferredCredentialEndpoint: context.deferredCredentialEndpoint,
      refreshToken: context.refreshToken)
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    let response = try await networkService.request(OpenIDEndpoint.status(url: url))
    return try jwsDecoder.decode(TokenStatusList.self, from: response.data)
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.vcSdJwsDecoder) private var vcSdJwsDecoder: VcSdJWSDecoderProtocol
  @Injected(\NetworkContainer.decoder) private var jsonDecoder: JSONDecoder
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.jweDecrypter) private var jweDecrypter: JWEDecrypterProtocol
  @Injected(\.isBatchIssuanceEnabled) private var isBatchIssuanceEnabled
  @Injected(\.oAuthErrorParser) private var oAuthErrorParser: OAuthErrorParserProtocol
  @Injected(\.openID4VCIErrorParser) private var openID4VCIErrorParser: OpenID4VCIErrorParserProtocol

  private func parseMetadataResponse(_ response: Response, from endpoint: URL) async throws -> CredentialIssuerMetadataResponse {
    switch ContentType(response.response) {
    case .json:
      let metadata = try jsonDecoder.decode(CredentialIssuerMetadata.self, from: response.data)
      return CredentialIssuerMetadataResponse(metadata: metadata, raw: response.data)
    case .jwt:
      let jws = try jwsDecoder.decode(CredentialIssuerMetadataJWT.self, from: response.data)
      try await jwsValidator.validate(jws)
      guard jws.payload.subject == endpoint.absoluteString else {
        throw OpenIdRepositoryError.invalidCredentialIssuerMetadataJWT
      }
      let metadata = jws.payload.credentialIssuerMetadata

      guard let rawPayloadData = jws.rawPayload.data(using: .utf8) else {
        throw OpenIdRepositoryError.invalidCredentialIssuerMetadata
      }
      return CredentialIssuerMetadataResponse(metadata: metadata, raw: rawPayloadData)
    }
  }

  private func parseOpenIdConfigurationResponse(_ response: Response, from endpoint: URL) async throws -> OpenIdConfiguration {
    switch ContentType(response.response) {
    case .json:
      return try jsonDecoder.decode(OpenIdConfiguration.self, from: response.data)
    case .jwt:
      let jws = try jwsDecoder.decode(OpenIdConfigurationJWT.self, from: response.data)
      try await jwsValidator.validate(jws)
      guard jws.payload.subject == endpoint.absoluteString else {
        throw OpenIdRepositoryError.invalidOpenIdConfigurationJWT
      }
      return jws.payload.openIdConfiguration
    }
  }

  private func fetchCredential(
    endpoint: OpenIDEndpoint,
    accessToken: String,
    format: String,
    privateKey: SecKey? = nil,
    deferredCredentialEndpoint: URL?,
    refreshToken: String? = nil) async throws
    -> FetchAnyCredentialResult.Credentials
  {
    do {
      let response = try await networkService.request(endpoint)

      switch ContentType(response.response) {
      case .json:
        return try getAnyCredentialResult(
          from: response.statusCode,
          data: response.data,
          accessToken: accessToken,
          format: format,
          deferredCredentialEndpoint: deferredCredentialEndpoint,
          refreshToken: refreshToken)
      case .jwt:
        guard let privateKey else {
          throw OpenIdRepositoryError.missingCredentialResponsePrivateKey
        }
        let decryptedPayload = try jweDecrypter.decrypt(payload: response.data, privateKey: privateKey)
        return try getAnyCredentialResult(
          from: response.statusCode,
          data: decryptedPayload,
          accessToken: accessToken,
          format: format,
          deferredCredentialEndpoint: deferredCredentialEndpoint,
          refreshToken: refreshToken)
      }
    } catch {
      throw openID4VCIErrorParser.parse(error)
    }
  }

  private func getAnyCredentialResult(from statusCode: Int, data: Data, accessToken: String, format: String, deferredCredentialEndpoint: URL?, refreshToken: String? = nil) throws -> FetchAnyCredentialResult.Credentials {
    var credential: FetchAnyCredentialResult.Credentials

    if statusCode == 202 { // see RFC 9110 §15.3.3 for status codes
      let deferred = try JSONDecoder().decode(CredentialResponseDeferred.self, from: data)
      credential = try .deferred(
        getDeferredCredential(
          from: deferred,
          accessToken: accessToken,
          format: format,
          deferredCredentialEndpoint: deferredCredentialEndpoint,
          refreshToken: refreshToken))
    } else if statusCode == 200 {
      let immediate = try JSONDecoder().decode(CredentialResponseImmediate.self, from: data)
      let credentials = try getAnyCredentials(from: immediate.credentials)

      if credentials.count > 1, isBatchIssuanceEnabled {
        credential = .batch(credentials: credentials)
      } else if let firstCredential = credentials.first {
        credential = .credential(firstCredential)
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
    accessToken: String,
    format: String,
    deferredCredentialEndpoint: URL?,
    refreshToken: String? = nil) throws
    -> DeferredCredentialContext
  {
    guard let endpoint = deferredCredentialEndpoint?.absoluteString else {
      throw OpenIdRepositoryError.missingDeferredCredentialEndpoint
    }

    return DeferredCredentialContext(
      transactionId: credentialResponse.transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      interval: credentialResponse.interval,
      refreshToken: refreshToken)
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
  case invalidToken(String)
  case insufficientScope(String)

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
  case expiredAccessToken
}
