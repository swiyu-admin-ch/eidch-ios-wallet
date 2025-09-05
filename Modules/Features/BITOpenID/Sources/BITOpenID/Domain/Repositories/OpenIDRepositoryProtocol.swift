import BITCrypto
import BITJWT
import BITNetworking
import Foundation
import Spyable

@Spyable
public protocol OpenIDRepositoryProtocol {
  func fetchVcSchemaData(from url: URL) async throws -> VcSchema
  func fetchTypeMetadata(from url: URL) async throws -> NetworkResponse<TypeMetadata>
  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialMetadataResponse
  func fetchOpenIdConfiguration(from issuerURL: URL) async throws -> OpenIdConfiguration
  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo
  func fetchAccessToken(from url: URL, preAuthorizedCode: String) async throws -> AccessToken
  func fetchCredential(with context: FetchCredentialContext, credentialRequestBody: VcSdJwtCredentialRequestBody) async throws -> FetchAnyCredentialResult
  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList>
  func fetchTrustStatements(from url: URL, for subjectDid: String) async throws -> [TrustStatement]
}
