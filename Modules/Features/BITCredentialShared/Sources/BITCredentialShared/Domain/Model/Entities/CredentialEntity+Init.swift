import BITEntities
import Foundation

extension CredentialEntity {

  // MARK: Lifecycle

  public convenience init(credential: Credential) {
    self.init()
    id = credential.id
    setValues(from: credential)

    clusters.append(objectsIn: credential.clusters.map(CredentialClaimClusterEntity.init))
    issuerDisplays.append(objectsIn: credential.issuerDisplays.map(CredentialIssuerDisplayEntity.init))
    displays.append(objectsIn: credential.displays.map(CredentialDisplayEntity.init))
    rawCredentialData = credential.rawCredentialData.flatMap(RawCredentialDataEntity.init)
  }

  // MARK: Public

  public func setValues(from credential: Credential) {
    status = credential.status.rawValue
    keyBindingIdentifier = credential.keyBindingIdentifier
    keyBindingAlgorithm = credential.keyBindingAlgorithm
    payload = credential.payload
    format = credential.format
    issuer = credential.issuer
    validFrom = credential.validFrom
    validUntil = credential.validUntil
    createdAt = credential.createdAt
    updatedAt = credential.updatedAt
  }

}
