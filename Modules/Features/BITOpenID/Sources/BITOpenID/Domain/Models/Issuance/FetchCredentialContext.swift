import Foundation

public class FetchCredentialContext {

  // MARK: Lifecycle

  init(
    credentialConfigurationId: String,
    format: String,
    selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported,
    credentialIssuer: String,
    holderBindingContext: HolderBindingContext?,
    accessToken: AccessToken,
    nonce: Nonce? = nil,
    credentialEndpoint: URL,
    createdAt: Date = .now,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.credentialConfigurationId = credentialConfigurationId
    self.format = format
    self.selectedCredential = selectedCredential
    self.credentialIssuer = credentialIssuer
    self.holderBindingContext = holderBindingContext
    self.accessToken = accessToken
    self.nonce = nonce
    self.credentialEndpoint = credentialEndpoint
    self.createdAt = createdAt
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
  }

  // MARK: Internal

  let credentialConfigurationId: String
  let format: String
  let selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported
  let credentialIssuer: String
  let holderBindingContext: HolderBindingContext?
  let createdAt: Date
  let accessToken: AccessToken
  let nonce: Nonce?
  let credentialEndpoint: URL
  let deferredCredentialEndpoint: URL?
}
