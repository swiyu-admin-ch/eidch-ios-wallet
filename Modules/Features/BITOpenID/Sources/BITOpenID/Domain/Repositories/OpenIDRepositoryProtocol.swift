import BITAnyCredentialFormat
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
  func fetchNonce(from url: URL) async throws -> Nonce
  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequest) async throws -> FetchAnyCredentialResult
  func fetchCredential(from url: URL, transactionId: String, accessToken: String, format: String) async throws -> FetchAnyCredentialResult
  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList>
}
