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
      let clusters = createClusters(for: verifiableCredential, claimIds: claimIds)
      let displays = entity.displays
        .findDisplaysWithFallback()
        .map(CredentialDisplay.init)
        .map { $0.resolveClaimTemplate(with: verifiableCredential.clusters) }
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

  // MARK: Fileprivate

  fileprivate func resolveClaimTemplate(with clusters: List<CredentialClaimClusterEntity>) -> Self {
    var copy = self

    copy.summary = summary?.replacing(Self.regex) { match in
      let templateContent = String(match.1)
      guard
        let path = ClaimsPathPointer(templateContent),
        let claim = clusters.flatMap(\.claims).first(where: {
          guard let claimPath = ClaimsPathPointer($0.path) else { return false }
          return path.isPointing(at: claimPath)
        })
      else { return "" }
      return claim.value ?? "–"
    }
    return copy
  }

  // MARK: Private

  private static let regex = Regex {
    "{{"
    Capture {
      ZeroOrMore(.any, .reluctant)
    }
    "}}"
  }
}
