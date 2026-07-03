#if DEBUG
import Foundation
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITCredentialShared

extension ClaimsPathPointer {
  func findCluster(in clusters: [CredentialClaimCluster]) -> CredentialClaimCluster? {
    for cluster in clusters {
      if cluster.path == self {
        return cluster
      }

      if let childCluster = findCluster(in: cluster.childClusters) {
        return childCluster
      }
    }

    return nil
  }

  func findClaim(in cluster: CredentialClaimCluster) -> CredentialClaim? {
    if let claim = cluster.claims.first(where: { $0.path == self }) {
      return claim
    }

    for childCluster in cluster.childClusters {
      if let claim = findClaim(in: childCluster) {
        return claim
      }
    }

    return nil
  }

  func findClaim(in clusters: [CredentialClaimCluster]) -> CredentialClaim? {
    for cluster in clusters {
      if let claim = findClaim(in: cluster) {
        return claim
      }
    }

    return nil
  }
}
#endif
