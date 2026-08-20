import BITEntities
import Foundation

extension CredentialEntity {

  // MARK: Lifecycle

  public convenience init(verifiableCredential: VerifiableCredential) {
    self.init()
    id = verifiableCredential.id
    setValues(from: verifiableCredential)
  }

  public convenience init(deferredCredential: DeferredCredential) {
    self.init()
    id = deferredCredential.id
    setValues(from: deferredCredential)
  }

  // MARK: Public

  public func setValues(from credential: CredentialProtocol) {
    setBaseValues(from: credential)
  }

  public func setValues(from verifiableCredential: VerifiableCredential) {
    setBaseValues(from: verifiableCredential)

    if let currentVerifiableCredential = self.verifiableCredential {
      currentVerifiableCredential.setValues(from: verifiableCredential)
    } else {
      self.verifiableCredential = VerifiableCredentialEntity(verifiableCredential)
    }
    deferredCredential = nil
  }

  public func setValues(from deferredCredential: DeferredCredential) {
    setBaseValues(from: deferredCredential)

    if let currentDeferredCredential = self.deferredCredential {
      currentDeferredCredential.setValues(from: deferredCredential)
    } else {
      self.deferredCredential = DeferredCredentialEntity(deferredCredential)
    }
    verifiableCredential = nil
  }

  // MARK: Private

  private func setBaseValues(from credential: CredentialProtocol) {
    format = credential.format.rawValue
    issuerUrl = credential.issuerUrl.absoluteString
    selectedConfigurationId = credential.selectedConfigurationId
    createdAt = credential.createdAt
    if let currentAuthentication = authentication {
      currentAuthentication.setValues(from: credential.authentication)
    } else {
      authentication = CredentialAuthenticationEntity(credential.authentication)
    }
    let issuerDisplayEntities = credential.issuerDisplays.map(CredentialIssuerDisplayEntity.init)
    issuerDisplays.replaceWithUpserted(issuerDisplayEntities, in: realm)
    let displayEntities = credential.displays.map(CredentialDisplayEntity.init)
    displays.replaceWithUpserted(displayEntities, in: realm)
    rawCredentialData = credential.rawCredentialData
      .map(RawCredentialDataEntity.init)
      .map { $0.upserted(in: realm) }
  }
}
