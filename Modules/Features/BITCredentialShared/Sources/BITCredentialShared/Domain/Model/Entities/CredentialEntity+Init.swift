import BITEntities
import Foundation

extension CredentialEntity {

  // MARK: Lifecycle

  public convenience init(verifiableCredential: VerifiableCredential) {
    self.init(verifiableCredential)

    self.verifiableCredential = VerifiableCredentialEntity(verifiableCredential)
  }

  public convenience init(deferredCredential: DeferredCredential) {
    self.init(deferredCredential)

    self.deferredCredential = DeferredCredentialEntity(deferredCredential)
  }

  private convenience init(_ credential: CredentialProtocol) {
    self.init()
    id = credential.id
    format = credential.format
    selectedConfigurationId = credential.selectedConfigurationId
    createdAt = credential.createdAt
    issuerDisplays.append(objectsIn: credential.issuerDisplays.map(CredentialIssuerDisplayEntity.init))
    displays.append(objectsIn: credential.displays.map(CredentialDisplayEntity.init))
    keyBinding = credential.keyBinding.flatMap(CredentialKeyBindingEntity.init)
    rawCredentialData = credential.rawCredentialData.flatMap(RawCredentialDataEntity.init)
  }

  // MARK: Public

  public func setValues(from credential: VerifiableCredential) {
    verifiableCredential?.status = VerifiableCredentialEntity.CredentialStatus(credential.status)
  }

  public func setValues(from credential: DeferredCredential) {
    deferredCredential?.polledAt = credential.polledAt
    deferredCredential?.pollingInterval = credential.pollingInterval
  }
}
