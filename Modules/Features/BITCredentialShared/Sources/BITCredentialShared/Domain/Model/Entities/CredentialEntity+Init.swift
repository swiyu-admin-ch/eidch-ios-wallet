import BITEntities
import Foundation

extension CredentialEntity {

  // MARK: Lifecycle

  public convenience init(credential: Credential) {
    self.init()
    id = credential.id
    setValues(from: credential)

    let sortedClusters = credential.clusters.sorted(by: { $0.order < $1.order })
    clusters.insert(contentsOf: sortedClusters.map(CredentialClaimClusterEntity.init), at: 0)
    keyBinding = credential.keyBinding.flatMap(CredentialKeyBindingEntity.init)
    issuerDisplays.append(objectsIn: credential.issuerDisplays.map(CredentialIssuerDisplayEntity.init))
    displays.append(objectsIn: credential.displays.map(CredentialDisplayEntity.init))
    rawCredentialData = credential.rawCredentialData.flatMap(RawCredentialDataEntity.init)
  }

  // MARK: Public

  public func setValues(from credential: Credential) {
    status = credential.status.rawValue
    payload = credential.payload
    format = credential.format
    issuer = credential.issuer
    validFrom = credential.validFrom
    validUntil = credential.validUntil
    createdAt = credential.createdAt
    updatedAt = credential.updatedAt
  }

}
