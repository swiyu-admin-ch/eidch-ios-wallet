import BITActivity
import BITCredential
import BITCredentialShared
import BITOpenID
import Foundation

struct ActivityCredentialViewModel {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, activity: Activity) {
    let credentialViewModel = VerifiableCredentialViewModel(credential: credential)
    credentialId = credential.id
    name = credentialViewModel.credentialDisplay?.name
    summary = credentialViewModel.credentialDisplay?.summary
    backgroundColor = credentialViewModel.credentialDisplay?.backgroundColor
    logoBase64 = credentialViewModel.credentialDisplay?.logoBase64
    environment = credential.environment
    clusters = credential.clusters.compactMap {
      Self.filterClusterClaims($0, activityClaims: activity.claims.map(\.credentialClaimId))
    }
  }

  // MARK: Internal

  let credentialId: UUID
  let name: String?
  let summary: String?
  let backgroundColor: String?
  let logoBase64: Data?
  let environment: TrustEnvironment
  let clusters: [CredentialClaimCluster]

  // MARK: Private

  private static func filterClusterClaims(_ cluster: CredentialClaimCluster, activityClaims: [UUID]) -> CredentialClaimCluster? {
    let claims = cluster.claims.filter { claim in
      activityClaims.contains(claim.id)
    }
    let childClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, activityClaims: activityClaims)
    }
    guard !claims.isEmpty || !childClusters.isEmpty else { return nil }
    return CredentialClaimCluster(id: cluster.id, order: cluster.order, claims: claims, childClusters: childClusters, displays: cluster.displays)
  }
}
