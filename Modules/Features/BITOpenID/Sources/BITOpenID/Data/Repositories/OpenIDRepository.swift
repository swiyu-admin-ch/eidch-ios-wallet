import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITNetworking
import BITSdJWT
import Factory
import Foundation
import Moya

// MARK: - OpenIDRepository

struct OpenIDRepository: OpenIDRepositoryProtocol {

  // MARK: Internal

  func fetchVcSchemaData(from url: URL) async throws -> VcSchema {
    try await networkService.request(OpenIDEndpoint.vcSchema(url: url)).data
  }

  /// Retrieving Type Metadata from a registry given as the url parameter
  /// - Documentation: [SD-JWT-based Verifiable Credentials - Draft 06](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-06.html#name-from-a-registry)
  func fetchTypeMetadata(from url: URL) async throws -> NetworkResponse<TypeMetadata> {
    try await networkService.request(OpenIDEndpoint.typeMetadata(url: url))
  }

  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialMetadataResponse {
    let response: NetworkResponse<CredentialMetadata> = try await networkService.request(OpenIDEndpoint.metadata(fromIssuerUrl: issuerUrl))
    return CredentialMetadataResponse(metadata: response.object, raw: response.data)
  }

  func fetchOpenIdConfiguration(from issuerURL: URL) async throws -> OpenIdConfiguration {
    do {
      return try await networkService.request(OpenIDEndpoint.openIdConfiguration(issuerURL: issuerURL))
    } catch let error as NetworkError where error.status == .notFound {
      return try await networkService.request(OpenIDEndpoint.fallbackOpenIdConfiguration(issuerUrl: issuerURL))
    } catch {
      throw error
    }
  }

  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo {
    try await networkService.request(OpenIDEndpoint.publicKeyInfo(jwksUrl: jwksUrl))
  }

  func fetchAccessToken(from url: URL, preAuthorizedCode: String) async throws -> AccessToken {
    try await networkService.request(OpenIDEndpoint.accessToken(fromTokenUrl: url, preAuthorizedCode: preAuthorizedCode))
  }

  func fetchCredential(with context: FetchCredentialContext, credentialRequestBody: VcSdJwtCredentialRequestBody) async throws -> FetchAnyCredentialResult {
    let result: (credentialResponse: CredentialResponse, response: Response) = try await networkService.request(
      OpenIDEndpoint.credential(
        url: context.credentialEndpoint,
        body: credentialRequestBody,
        acccessToken: context.accessToken.accessToken)
    )

    // A deferred credential is expected when http status code is 202 (see RFC 9110 §15.3.3)

    var credential: FetchAnyCredentialResult

    if result.response.statusCode == 202 {
      credential = try .deferred(getDeferredCredential(from: result.credentialResponse, context: context))
    } else if result.response.statusCode == 200 {
      credential = try .credential(getCredential(from: result.credentialResponse))
    } else {
      throw OpenIdRepositoryError.unsupportedCredentialStatusCode
    }

    return credential
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    let response = try await networkService.request(OpenIDEndpoint.status(url: url))
    return try jwsDecoder.decode(TokenStatusList.self, from: response.data)
  }

  func refreshDeferredCredential(from url: URL, transactionId: String, acccessToken: String, format: String) async throws -> AnyCredential {
    let authPlugin = AccessTokenPlugin(tokenClosure: { _ in acccessToken })

    do {
      let credentialResponse: CredentialResponse = try await networkService.request(OpenIDEndpoint.deferredCredential(url: url, transactionId: transactionId), plugins: [authPlugin])

      return try getCredential(from: credentialResponse)
    } catch let error as NetworkError where error.status == .badRequest {
      throw try parseDeferredCredentialError(error)
    } catch {
      throw error
    }
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol
  @Injected(\.defaultDeferredCredentialInterval) private var defaultDeferredCredentialInterval: Int

  private func getDeferredCredential(from credentialResponse: CredentialResponse, context: FetchCredentialContext) throws -> DeferredCredentialRequest {
    guard
      let transactionId = credentialResponse.transactionId,
      let endpoint = context.deferredCredentialEndpoint?.absoluteString
    else {
      throw OpenIdRepositoryError.credentialResponseValidationFailed
    }

    return DeferredCredentialRequest(
      transactionId: transactionId,
      accessToken: context.accessToken.accessToken,
      endpoint: endpoint,
      format: context.format,
      interval: credentialResponse.interval ?? defaultDeferredCredentialInterval)
  }

  private func getCredential(from credentialResponse: CredentialResponse) throws -> AnyCredential {
    guard
      let rawCredential = credentialResponse.rawCredential,
      let credentialData = rawCredential.data(using: .utf8)
    else {
      throw OpenIdRepositoryError.credentialResponseValidationFailed
    }

    return try sdJwsDecoder.decode(VcSdJwtPayload.self, from: credentialData)
  }

  private func parseDeferredCredentialError(_ error: NetworkError) throws -> Error {
    let errorResponse = try JSONDecoder().decode(DeferredCredentialErrorResponse.self, from: error.response?.data ?? Data())

    guard errorResponse.error == .issuancePending else {
      throw error
    }

    throw OpenIdRepositoryError.credentialIssuancePending(interval: errorResponse.interval ?? defaultDeferredCredentialInterval)
  }
}

// MARK: - OpenIdRepositoryError

public enum OpenIdRepositoryError: Error, Equatable {
  case presentationProcessClosed
  case authorizationRequestObjectNotFound
  case credentialResponseValidationFailed
  case unsupportedCredentialStatusCode
  case credentialIssuancePending(interval: Int)
}
