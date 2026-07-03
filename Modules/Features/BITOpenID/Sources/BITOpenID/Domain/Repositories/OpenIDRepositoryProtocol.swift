import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITNetworking
import BITVault
import Foundation
import Moya
import Spyable

@Spyable
public protocol OpenIDRepositoryProtocol {
  func fetchVcSchemaData(from url: URL) async throws -> VcSchema
  func fetchTypeMetadata(from url: URL) async throws -> (object: TypeMetadata, response: Response)
  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialIssuerMetadataResponse
  func fetchOpenIdConfiguration(from issuerURL: URL) async throws -> OpenIdConfiguration
  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo
  func fetchAccessToken(
    from url: URL,
    preAuthorizedCode: String,
    dpopKeyPair: VaultKeyPair?,
    dpopNonce: String?,
    dpopKeyAttestationJWS: String?) async throws
    -> IssuanceAuthorization
  func refreshAccessToken(
    from url: URL,
    refreshToken: String,
    dpopKeyPair: VaultKeyPair?,
    dpopNonce: String?) async throws
    -> IssuanceAuthorization
  func fetchNonce(from url: URL) async throws -> (nonce: Nonce, dpopNonce: String?)
  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequestBody) async throws -> FetchAnyCredentialResult.Credentials
  func fetchCredential(with context: FetchDeferredCredentialContext, requestBody: DeferredCredentialRequestBody) async throws -> FetchAnyCredentialResult.Credentials
  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList>
}
