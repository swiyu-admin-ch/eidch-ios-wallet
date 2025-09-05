import BITCrypto
import BITJWT
import BITNetworking
import BITSdJWT
import Factory
import Foundation
import Moya
import Spyable

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
      credential = try getDeferredCredential(from: result.credentialResponse, context: context)
    } else if result.response.statusCode == 200 {
      #warning("Temporary fix until deployment of new image from OMNI / DONUM -> try getCredential(from: result.credentialResponse) instead")
      do {
        credential = try getCredential(from: result.credentialResponse)
      } catch OpenIdRepositoryError.credentialResponseValidationFailed {
        credential = try getDeferredCredential(from: result.credentialResponse, context: context)
      } catch {
        throw error
      }
    } else {
      throw OpenIdRepositoryError.unsupportedCredentialStatusCode
    }

    return credential
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    let response = try await networkService.request(OpenIDEndpoint.status(url: url))
    return try jwsDecoder.decode(TokenStatusList.self, from: response.data)
  }

  func fetchTrustStatements(from url: URL, for subjectDid: String) async throws -> [TrustStatement] {
    let statements: [String] = try await networkService.request(OpenIDEndpoint.trustStatements(url: url, subjectDid: subjectDid))
    return try statements.map {
      let data = $0.data(using: .utf8) ?? Data()
      return try sdJwsDecoder.decode(TrustStatementPayload.self, from: data)
    }
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol

  private func getDeferredCredential(from credentialResponse: CredentialResponse, context: FetchCredentialContext) throws -> FetchAnyCredentialResult {
    guard
      let transactionId = credentialResponse.transactionId
    else {
      throw OpenIdRepositoryError.credentialResponseValidationFailed
    }

    #warning("TODO: Null check `deferredCredentialEndpoint` when implemented by Donum")
    return .deferred(transactionId: transactionId, accessToken: context.accessToken.accessToken, endpoint: context.deferredCredentialEndpoint?.absoluteString ?? "")
  }

  private func getCredential(from credentialResponse: CredentialResponse) throws -> FetchAnyCredentialResult {
    guard
      let rawCredential = credentialResponse.rawCredential,
      let credentialData = rawCredential.data(using: .utf8),
      let vcSdJwt = try? sdJwsDecoder.decode(VcSdJwtPayload.self, from: credentialData)
    else {
      throw OpenIdRepositoryError.credentialResponseValidationFailed
    }

    return .credential(vcSdJwt)
  }
}

// MARK: - OpenIdRepositoryError

enum OpenIdRepositoryError: Error {
  case presentationProcessClosed
  case authorizationRequestObjectNotFound
  case credentialResponseValidationFailed
  case unsupportedCredentialStatusCode
}
