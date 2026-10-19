#if DEBUG
import BITDataStore
import RealmSwift
@testable import BITCore

extension CredentialRenderingEntity: Mockable {
  public struct Mock {
    public static func create(
      displays: [CredentialDisplayEntity] = [],
      issuerDisplays: [CredentialIssuerDisplayEntity] = [],
      clusters: [CredentialClaimClusterEntity] = [],
      createParent: Bool = false) throws
      -> CredentialRenderingEntity
    {
      let entity = CredentialRenderingEntity()
      entity.displays.append(objectsIn: displays)
      entity.issuerDisplays.append(objectsIn: issuerDisplays)
      entity.clusters.append(objectsIn: clusters)
      entity.updateContentHash()

      try Realm.save(entity)
      if createParent {
        _ = try CredentialEntity.Mock.create(rendering: entity)
      }
      return entity
    }
  }
}
#endif
