#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialEntity: Mockable {
  public struct Mock {
    public static func create(
      id: UUID = UUID(),
      verifiableCredential: VerifiableCredentialEntity? = nil,
      displays: [CredentialDisplayEntity] = [],
      issuerDisplays: [CredentialIssuerDisplayEntity] = [],
      clusters: [CredentialClaimClusterEntity] = [],
      rendering: CredentialRenderingEntity? = nil,
      activities: [CredentialActivityEntity] = []) throws
      -> CredentialEntity
    {
      let entity = CredentialEntity()
      entity.id = id
      entity.verifiableCredential = verifiableCredential
      entity.credentialRendering = try rendering ?? CredentialRenderingEntity.Mock.create(
        displays: displays,
        issuerDisplays: issuerDisplays,
        clusters: clusters)

      let activityList = List<CredentialActivityEntity>()
      activityList.append(objectsIn: activities)
      entity.activities = activityList

      try Realm.save(entity)
      return entity
    }
  }
}
#endif
