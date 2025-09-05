import Foundation

public class FetchCredentialContext {

  // MARK: Lifecycle

  init(
    format: String,
    selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported,
    credentialOffers: [String],
    credentialIssuer: String,
    holderBindingContext: HolderBindingContext?,
    accessToken: AccessToken,
    credentialEndpoint: URL,
    createdAt: Date = .now,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.format = format
    self.selectedCredential = selectedCredential
    self.credentialOffers = credentialOffers
    self.credentialIssuer = credentialIssuer
    self.holderBindingContext = holderBindingContext
    self.accessToken = accessToken
    self.credentialEndpoint = credentialEndpoint
    self.createdAt = createdAt
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
  }

  // MARK: Internal

  let format: String
  let selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported
  let credentialOffers: [String]
  let credentialIssuer: String
  let holderBindingContext: HolderBindingContext?
  let createdAt: Date
  let accessToken: AccessToken
  let credentialEndpoint: URL
  let deferredCredentialEndpoint: URL?
}
