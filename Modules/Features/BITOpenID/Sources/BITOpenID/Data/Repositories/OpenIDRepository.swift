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

  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialMetadataResponse {
    let response = try await networkService.request(OpenIDEndpoint.metadata(fromIssuerUrl: issuerUrl))
    return try await parseMetadataResponse(response, from: issuerUrl)
  }

  func fetchOpenIdConfiguration(from issuerURL: URL) async throws -> OpenIdConfiguration {
    let response = try await networkService.request(OpenIDEndpoint.openIdConfiguration(issuerURL: issuerURL))
    return try await parseOpenIdConfigurationResponse(response, from: issuerURL)
  }

  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo {
    try await networkService.request(OpenIDEndpoint.publicKeyInfo(jwksUrl: jwksUrl))
  }

  func fetchAccessToken(from url: URL, preAuthorizedCode: String) async throws -> AccessToken {
    try await networkService.request(OpenIDEndpoint.accessToken(fromTokenUrl: url, preAuthorizedCode: preAuthorizedCode))
  }

  func fetchNonce(from url: URL) async throws -> Nonce {
    try await networkService.request(OpenIDEndpoint.nonce(url: url))
  }

  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequestBody) async throws -> FetchAnyCredentialResult {
    let endpoint = OpenIDEndpoint.credential(
      url: context.credentialEndpoint,
      body: credentialRequest,
      accessToken: context.accessToken)

    return try await fetchCredential(
      endpoint: endpoint,
      accessToken: context.accessToken.accessToken,
      format: context.format,
      privateKey: context.credentialEncryptionContext?.responseKeyPair?.privateKey,
      deferredCredentialEndpoint: context.deferredCredentialEndpoint)
  }

  func fetchCredential(
    from deferredCredentialEndpoint: URL,
    requestBody: DeferredCredentialRequestBody,
    accessToken: String,
    format: String,
    privateKey: SecKey?) async throws
    -> FetchAnyCredentialResult
  {
    let endpoint = OpenIDEndpoint.deferredCredential(
      url: deferredCredentialEndpoint,
      body: requestBody,
      accessToken: accessToken)

    return try await fetchCredential(
      endpoint: endpoint,
      accessToken: accessToken,
      format: format,
      privateKey: privateKey,
      deferredCredentialEndpoint: deferredCredentialEndpoint)
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    let response = try await networkService.request(OpenIDEndpoint.status(url: url))
    return try jwsDecoder.decode(TokenStatusList.self, from: response.data)
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol
  @Injected(\NetworkContainer.decoder) private var jsonDecoder: JSONDecoder
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.jweDecrypter) private var jweDecrypter: JWEDecrypterProtocol

  private func parseMetadataResponse(_ response: Response, from endpoint: URL) async throws -> CredentialMetadataResponse {
    switch ContentType(response.response) {
    case .json:
      let metadata = try jsonDecoder.decode(CredentialMetadata.self, from: response.data)
      return CredentialMetadataResponse(metadata: metadata, raw: response.data)
    case .jwt:
      let jws = try jwsDecoder.decode(CredentialMetadataJWT.self, from: response.data)
      try await jwsValidator.validate(jws)
      guard jws.payload.subject == endpoint.absoluteString else {
        throw OpenIdRepositoryError.invalidCredentialMetadataJWT
      }
      let metadata = jws.payload.credentialMetadata

      guard let rawPayloadData = jws.rawPayload.data(using: .utf8) else {
        throw OpenIdRepositoryError.invalidCredentialMetadata
      }
      return CredentialMetadataResponse(metadata: metadata, raw: rawPayloadData)
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
    deferredCredentialEndpoint: URL?) async throws
    -> FetchAnyCredentialResult
  {
    do {
      let response = try await networkService.request(endpoint)

      switch ContentType(response.response) {
      case .json:
        return try getAnyCredentialResult(from: response.statusCode, data: response.data, accessToken: accessToken, format: format, deferredCredentialEndpoint: deferredCredentialEndpoint)
      case .jwt:
        guard let privateKey else {
          throw OpenIdRepositoryError.missingCredentialResponsePrivateKey
        }
        let decryptedPayload = try jweDecrypter.decrypt(payload: response.data, privateKey: privateKey)
        return try getAnyCredentialResult(from: response.statusCode, data: decryptedPayload, accessToken: accessToken, format: format, deferredCredentialEndpoint: deferredCredentialEndpoint)
      }
    } catch {
      throw try parseCredentialResponseError(error)
    }
  }

  private func getAnyCredentialResult(from statusCode: Int, data: Data, accessToken: String, format: String, deferredCredentialEndpoint: URL?) throws -> FetchAnyCredentialResult {
    var credential: FetchAnyCredentialResult

    if statusCode == 202 { // see RFC 9110 §15.3.3 for status codes
      let deferred = try JSONDecoder().decode(CredentialResponseDeferred.self, from: data)
      credential = try .deferred(getDeferredCredential(from: deferred, accessToken: accessToken, format: format, deferredCredentialEndpoint: deferredCredentialEndpoint))
    } else if statusCode == 200 {
      let immediate = try JSONDecoder().decode(CredentialResponseImmediate.self, from: data)
      // batch issuance to be implemented, just taking first for now
      credential = try .credential(getAnyCredential(from: immediate.credentials.first))
    } else {
      throw OpenIdRepositoryError.unsupportedCredentialStatusCode
    }
    return credential
  }

  private func getDeferredCredential(
    from credentialResponse: CredentialResponseDeferred,
    accessToken: String,
    format: String,
    deferredCredentialEndpoint: URL?) throws
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
      interval: credentialResponse.interval)
  }

  private func getAnyCredential(from raw: CredentialResponseImmediate.Credential?) throws -> AnyCredential {
    guard let raw, let credentialData = raw.credential.data(using: .utf8) else {
      throw OpenIdRepositoryError.missingImmediateCredentialData
    }

    return try sdJwsDecoder.decode(VcSdJwt.self, from: credentialData)
  }

  private func parseCredentialResponseError(_ error: Error) throws -> Error {
    guard
      let networkError = error as? NetworkError,
      networkError.status == .badRequest,
      let errorData = networkError.response?.data,
      let errorResponse = try? JSONDecoder().decode(CredentialResponseError.self, from: errorData),
      errorResponse.error == .credentialRequestDenied
    else {
      throw error
    }

    throw OpenIdRepositoryError.invalidCredential
  }
}

// MARK: - OpenIdRepositoryError

public enum OpenIdRepositoryError: Error, Equatable {
  case presentationProcessClosed
  case unsupportedCredentialStatusCode
  case invalidCredential
  case missingDeferredCredentialEndpoint
  case missingImmediateCredentialData
  case invalidCredentialMetadata
  case invalidCredentialMetadataJWT
  case invalidOpenIdConfigurationJWT
  case missingCredentialResponsePrivateKey
}
