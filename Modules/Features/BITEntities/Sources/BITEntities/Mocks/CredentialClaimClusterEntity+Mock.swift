#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension CredentialClaimClusterEntity: Mockable {
  public struct Mock {
    public static func create(
      id: UUID = UUID(),
      claims: [CredentialClaimEntity] = [],
      childClusters: [CredentialClaimClusterEntity] = [],
      createParent: Bool = true) throws
      -> CredentialClaimClusterEntity
    {
      let entity = CredentialClaimClusterEntity()
      entity.id = id

      let claimList = List<CredentialClaimEntity>()
      claimList.append(objectsIn: claims)
      entity.claims = claimList

      let childClusterList = List<CredentialClaimClusterEntity>()
      childClusterList.append(objectsIn: childClusters)
      entity.childClusters = childClusterList

      try Realm.save(entity)
      if createParent {
        _ = try VerifiableCredentialEntity.Mock.create(clusters: [entity])
      }
      return entity
    }
  }
}
#endif
