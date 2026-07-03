import BITClaimsPathPointer
import BITCore
import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - CompatibleCredential

public struct CompatibleCredential: Identifiable, Equatable {

  // MARK: Lifecycle

  public init(credential: VerifiableCredential, presentingPaths: [ClaimsPathPointer], dcqlQueryId: String? = nil) {
    self.credential = credential
    id = credential.id

    self.presentingPaths = presentingPaths
    self.dcqlQueryId = dcqlQueryId
  }

  // MARK: Public

  public let id: UUID
  public let credential: VerifiableCredential
  public let dcqlQueryId: String?

  public var credentialName: String {
    credential.displays.first?.name ?? "Unknown Credential"
  }

  public var requestedClaimClusters: [CredentialClaimCluster] {
    credential.resolvedClusters.compactMap {
      filterClusterClaims($0, presentingPaths: presentingPaths)
    }
  }

  // MARK: Internal

  let presentingPaths: [ClaimsPathPointer]

  // MARK: Private

  private func filterClusterClaims(_ cluster: CredentialClaimCluster, presentingPaths: [ClaimsPathPointer]) -> CredentialClaimCluster? {
    if presentingPaths.contains(where: { $0.pointsAtSetOf(cluster.path) }) { return cluster }
    let requestedClaims = cluster.claims.filter { claim in
      matchRequestedClaim(claim, presentingPaths: presentingPaths)
    }
    let requestedChildClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, presentingPaths: presentingPaths)
    }
    guard !requestedClaims.isEmpty || !requestedChildClusters.isEmpty else { return nil }
    return CredentialClaimCluster(
      id: cluster.id,
      path: cluster.path,
      order: cluster.order,
      isSensitive: cluster.isSensitive,
      claims: requestedClaims,
      childClusters: requestedChildClusters,
      displays: cluster.displays)
  }

  private func matchRequestedClaim(_ claim: CredentialClaim, presentingPaths: [ClaimsPathPointer]) -> Bool {
    presentingPaths.contains { path in
      path.pointsAtSetOf(claim.path)
    }
  }
}
