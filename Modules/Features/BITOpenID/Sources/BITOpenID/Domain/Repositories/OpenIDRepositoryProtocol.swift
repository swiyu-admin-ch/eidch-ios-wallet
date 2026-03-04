import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITNetworking
import Foundation
import Moya
import Spyable

@Spyable
public protocol OpenIDRepositoryProtocol {
  func fetchVcSchemaData(from url: URL) async throws -> VcSchema
  func fetchTypeMetadata(from url: URL) async throws -> (object: TypeMetadata, response: Response)
  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialMetadataResponse
  func fetchOpenIdConfiguration(from issuerURL: URL) async throws -> OpenIdConfiguration
  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo
  func fetchAccessToken(from url: URL, preAuthorizedCode: String) async throws -> AccessToken
  func fetchNonce(from url: URL) async throws -> Nonce
  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequestBody) async throws -> FetchAnyCredentialResult
  func fetchCredential(from url: URL, requestBody: DeferredCredentialRequestBody, accessToken: String, format: String, privateKey: SecKey?) async throws -> FetchAnyCredentialResult
  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList>
}
