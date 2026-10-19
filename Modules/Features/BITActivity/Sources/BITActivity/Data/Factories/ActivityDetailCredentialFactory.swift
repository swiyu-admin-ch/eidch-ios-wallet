import BITClaimsPathPointer
import BITCredentialShared
import BITEntities
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - ActivityDetailCredentialFactoryProtocol

@Spyable
protocol ActivityDetailCredentialFactoryProtocol: Sendable {
  func callAsFunction(_ entity: CredentialActivityEntity, paths: [String]) -> ActivityDetailCredential
}

// MARK: - ActivityDetailCredentialFactory

struct ActivityDetailCredentialFactory: ActivityDetailCredentialFactoryProtocol {

  // MARK: Internal

  func callAsFunction(_ entity: CredentialActivityEntity, paths: [String]) -> ActivityDetailCredential {
    let rendering = entity.credentialRendering
    let allClusters = rendering.map { Array($0.clusters) } ?? []
    let clusters = createClusters(for: rendering, paths: paths)
      .map { $0.resolvePathTemplates(using: allClusters) }
    let displays = (rendering?.displays.findDisplaysWithFallback() ?? [])
      .map(CredentialDisplay.init)
      .map { $0.resolvePathTemplates(using: allClusters) }

    return ActivityDetailCredential(
      id: entity.id,
      displays: displays,
      environment: TrustEnvironment(did: entity.issuer),
      clusters: clusters,
      statusListState: entity.bundleItem.map { CredentialStatus($0.statusListState) })
  }

  // MARK: Private

  private static func filterClusterClaims(_ cluster: CredentialClaimClusterEntity, paths: [String]) -> CredentialClaimCluster? {
    let claims = cluster.claims.filter { claim in
      paths.contains(claim.path)
    }
    let childClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, paths: paths)
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

  private func createClusters(for rendering: CredentialRenderingEntity?, paths: [String]) -> [CredentialClaimCluster] {
    rendering?.clusters
      .compactMap { cluster in
        Self.filterClusterClaims(cluster, paths: paths)
      } ?? []
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
