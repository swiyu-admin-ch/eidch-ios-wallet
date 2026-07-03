import BITClaimsPathPointer
import BITCore
import BITCredentialShared
import BITEntities
import BITOpenID
import Factory
import Foundation
import RealmSwift
import RegexBuilder
import Spyable

// MARK: - ActivityDetailCredentialFactoryProtocol

@Spyable
protocol ActivityDetailCredentialFactoryProtocol {
  func callAsFunction(_ entity: CredentialEntity, claimIds: [UUID]) -> ActivityDetailCredential
}

// MARK: - ActivityDetailCredentialFactory

struct ActivityDetailCredentialFactory: ActivityDetailCredentialFactoryProtocol {

  // MARK: Internal

  func callAsFunction(_ entity: CredentialEntity, claimIds: [UUID]) -> ActivityDetailCredential {
    if let verifiableCredential = entity.verifiableCredential {
      let allClusters = Array(verifiableCredential.clusters)
      var clusters = createClusters(for: verifiableCredential, claimIds: claimIds)
      clusters = clusters.map { $0.resolvePathTemplates(using: allClusters) }
      let displays = entity.displays
        .findDisplaysWithFallback()
        .map(CredentialDisplay.init)
        .map { $0.resolvePathTemplates(using: allClusters) }
      return ActivityDetailCredential(
        id: entity.id,
        displays: displays,
        environment: TrustEnvironment(did: verifiableCredential.issuer),
        clusters: clusters)
    }
    return ActivityDetailCredential(
      id: entity.id,
      displays: entity.displays.findDisplaysWithFallback().map(CredentialDisplay.init),
      environment: TrustEnvironment.external,
      clusters: [])
  }

  // MARK: Private

  private static func filterClusterClaims(_ cluster: CredentialClaimClusterEntity, claimIds: [UUID]) -> CredentialClaimCluster? {
    let claims = cluster.claims.filter { claim in
      claimIds.contains(claim.id)
    }
    let childClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, claimIds: claimIds)
    }
    guard !claims.isEmpty || !childClusters.isEmpty else { return nil }
    return CredentialClaimCluster(
      id: cluster.id,
      path: ClaimsPathPointer(cluster.path) ?? [],
      order: Int(cluster.order),
      claims: Array(claims).map(CredentialClaim.init),
      childClusters: Array(childClusters),
      displays: Array(cluster.displays).map(ClusterDisplay.init))
  }

  private func createClusters(for credential: VerifiableCredentialEntity, claimIds: [UUID]) -> [CredentialClaimCluster] {
    credential.clusters
      .compactMap { cluster in
        Self.filterClusterClaims(cluster, claimIds: claimIds)
      }
  }
}

#warning("TODO: should be moved to a CredentialDisplayFactory")
extension CredentialDisplay {

  fileprivate func resolvePathTemplates(using clusters: [CredentialClaimClusterEntity]) -> Self {
    var copy = self
    copy.summary = summary?.resolvePathTemplates(using: clusters)
    return copy
  }
}

extension CredentialClaimCluster {

  fileprivate func resolvePathTemplates(using clusters: [CredentialClaimClusterEntity]) -> Self {
    var copy = self
    copy.childClusters = childClusters.map { $0.resolvePathTemplates(using: clusters) }
    copy.displays = displays.map { $0.resolvePathTemplates(using: clusters, indices: path.allIndices) }
    return copy
  }
}

extension ClusterDisplay {

  fileprivate func resolvePathTemplates(using clusters: [CredentialClaimClusterEntity], indices: [Int]) -> Self {
    var copy = self
    copy.name = name.resolvePathTemplates(using: clusters, indices: indices)
    return copy
  }
}
