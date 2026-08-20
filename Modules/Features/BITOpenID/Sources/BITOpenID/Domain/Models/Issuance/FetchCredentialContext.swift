import BITAnyCredentialFormat
import BITCore
import BITVault
import Foundation

public class FetchCredentialContext: Changeable {

  // MARK: Lifecycle

  init(
    credentialConfigurationId: String,
    format: CredentialFormat,
    selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported,
    credentialIssuer: URL,
    holderBindings: [HolderBinding]?,
    authorization: IssuanceAuthorization,
    nonce: Nonce? = nil,
    credentialEndpoint: URL,
    credentialEncryptionContext: CredentialEncryptionContext,
    createdAt: Date = .now,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.credentialConfigurationId = credentialConfigurationId
    self.format = format
    self.selectedCredential = selectedCredential
    self.credentialIssuer = credentialIssuer
    self.holderBindings = holderBindings
    self.authorization = authorization
    self.nonce = nonce
    self.credentialEndpoint = credentialEndpoint
    self.credentialEncryptionContext = credentialEncryptionContext
    self.createdAt = createdAt
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
  }

  convenience init(
    credentialConfigurationId: String,
    format: CredentialFormat,
    selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported,
    credentialIssuer: URL,
    holderBindings: [HolderBinding]?,
    dpopKeyPair: VaultKeyPair? = nil,
    accessToken: AccessToken,
    nonce: Nonce? = nil,
    dpopNonce: String? = nil,
    credentialEndpoint: URL,
    credentialEncryptionContext: CredentialEncryptionContext,
    createdAt: Date = .now,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.init(
      credentialConfigurationId: credentialConfigurationId,
      format: format,
      selectedCredential: selectedCredential,
      credentialIssuer: credentialIssuer,
      holderBindings: holderBindings,
      authorization: IssuanceAuthorization(
        accessToken: accessToken,
        dpopKeyPair: dpopKeyPair,
        resourceServerDPoPNonce: dpopNonce),
      nonce: nonce,
      credentialEndpoint: credentialEndpoint,
      credentialEncryptionContext: credentialEncryptionContext,
      createdAt: createdAt,
      deferredCredentialEndpoint: deferredCredentialEndpoint)
  }

  // MARK: Internal

  let credentialConfigurationId: String
  let format: CredentialFormat
  let selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported
  let credentialIssuer: URL
  let holderBindings: [HolderBinding]?
  var authorization: IssuanceAuthorization
  let credentialEncryptionContext: CredentialEncryptionContext
  let createdAt: Date
  let nonce: Nonce?
  let credentialEndpoint: URL
  let deferredCredentialEndpoint: URL?

  var accessToken: AccessToken {
    authorization.accessToken
  }

  var dpopKeyPair: VaultKeyPair? {
    authorization.dpopKeyPair
  }

  var dpopNonce: String? {
    authorization.resourceServerDPoPNonce
  }
}
