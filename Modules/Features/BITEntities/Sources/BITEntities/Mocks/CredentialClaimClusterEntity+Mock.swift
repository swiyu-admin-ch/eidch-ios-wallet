#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialClaimClusterEntity: Mockable {
  public struct Mock {
    public static func create(
      id: UUID = UUID(),
      path: String = "[]",
      claims: [CredentialClaimEntity] = [],
      childClusters: [CredentialClaimClusterEntity] = [],
      displays: [CredentialClaimClusterDisplayEntity] = [],
      createParent: Bool = true) throws
      -> CredentialClaimClusterEntity
    {
      let entity = CredentialClaimClusterEntity()
      entity.id = id
      entity.path = path

      let claimList = List<CredentialClaimEntity>()
      claimList.append(objectsIn: claims)
      entity.claims = claimList

      let childClusterList = List<CredentialClaimClusterEntity>()
      childClusterList.append(objectsIn: childClusters)
      entity.childClusters = childClusterList

      let displayList = List<CredentialClaimClusterDisplayEntity>()
      displayList.append(objectsIn: displays)
      entity.displays = displayList

      try Realm.save(entity)
      if createParent {
        _ = try VerifiableCredentialEntity.Mock.create(clusters: [entity])
      }
      return entity
    }
  }
}
#endif
