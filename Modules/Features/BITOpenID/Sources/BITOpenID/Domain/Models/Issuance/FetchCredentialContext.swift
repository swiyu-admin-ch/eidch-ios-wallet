import Foundation

public class FetchCredentialContext {

  // MARK: Lifecycle

  init(
    credentialConfigurationId: String,
    format: String,
    selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported,
    credentialIssuer: String,
    holderBindings: [HolderBinding]?,
    accessToken: AccessToken,
    nonce: Nonce? = nil,
    credentialEndpoint: URL,
    credentialEncryptionContext: CredentialEncryptionContext? = nil,
    createdAt: Date = .now,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.credentialConfigurationId = credentialConfigurationId
    self.format = format
    self.selectedCredential = selectedCredential
    self.credentialIssuer = credentialIssuer
    self.holderBindings = holderBindings
    self.accessToken = accessToken
    self.nonce = nonce
    self.credentialEndpoint = credentialEndpoint
    self.credentialEncryptionContext = credentialEncryptionContext
    self.createdAt = createdAt
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
  }

  // MARK: Internal

  let credentialConfigurationId: String
  let format: String
  let selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported
  let credentialIssuer: String
  let holderBindings: [HolderBinding]?
  let credentialEncryptionContext: CredentialEncryptionContext?
  let createdAt: Date
  let accessToken: AccessToken
  let nonce: Nonce?
  let credentialEndpoint: URL
  let deferredCredentialEndpoint: URL?
}
