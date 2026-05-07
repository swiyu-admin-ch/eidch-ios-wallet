#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension VerifiableCredentialEntity: Mockable {
  public struct Mock {
    public static func create(issuer: String = "issuer", clusters: [CredentialClaimClusterEntity] = [], createParent: Bool = true) throws -> VerifiableCredentialEntity {
      let entity = VerifiableCredentialEntity()
      entity.issuer = issuer

      let clusterList = List<CredentialClaimClusterEntity>()
      clusterList.append(objectsIn: clusters)
      entity.clusters = clusterList

      try Realm.save(entity)
      if createParent {
        _ = try CredentialEntity.Mock.create(verifiableCredential: entity)
      }
      return entity
    }
  }
}
#endif
