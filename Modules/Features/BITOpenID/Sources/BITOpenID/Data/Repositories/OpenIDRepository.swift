import BITCrypto
import BITJWT
import BITNetworking
import BITSdJWT
import Factory
import Foundation
import Moya

// MARK: - OpenIdRepositoryError

enum OpenIdRepositoryError: Error {
  case presentationProcessClosed
  case authorizationRequestObjectNotFound
}

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

  func fetchCredential(from url: URL, credentialRequestBody: VcSdJwtCredentialRequestBody, acccessToken: AccessToken) async throws -> CredentialResponse {
    try await networkService.request(OpenIDEndpoint.credential(url: url, body: credentialRequestBody, acccessToken: acccessToken.accessToken))
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    let response = try await networkService.request(OpenIDEndpoint.status(url: url))
    return try jwsDecoder.decode(TokenStatusList.self, from: response.data)
  }

  func fetchRequestObject(from url: URL) async throws -> Data {
    do {
      return try await networkService.request(OpenIDEndpoint.requestObject(url: url)).data
    } catch let error as NetworkError where error.status == .gone {
      throw OpenIdRepositoryError.presentationProcessClosed
    } catch let error as NetworkError where error.status == .notFound {
      throw OpenIdRepositoryError.authorizationRequestObjectNotFound
    }
  }

  func fetchTrustStatements(from url: URL, issuerDid: String) async throws -> [TrustStatement] {
    let statements: [String] = try await networkService.request(OpenIDEndpoint.trustStatements(url: url, issuerDid: issuerDid))
    return try statements.map {
      let data = $0.data(using: .utf8) ?? Data()
      return try sdJwsDecoder.decode(TrustStatementPayload.self, from: data)
    }
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol
}
