import BITEntities
import Foundation

extension CredentialClaimClusterEntity {

  // MARK: Lifecycle

  public convenience init(cluster: CredentialClaimCluster) {
    self.init()
    id = cluster.id
    let sortedClaims = cluster.claims.sorted(by: { $0.order < $1.order })
    claims.insert(contentsOf: sortedClaims.map(CredentialClaimEntity.init), at: 0)
    childClusters.append(objectsIn: cluster.childClusters.map(CredentialClaimClusterEntity.init))
    displays.append(objectsIn: cluster.displays.map(CredentialClaimClusterDisplayEntity.init))
    setValues(from: cluster)
  }

  // MARK: Internal

  func setValues(from cluster: CredentialClaimCluster) {
    order = Int16(cluster.order)
  }

}
