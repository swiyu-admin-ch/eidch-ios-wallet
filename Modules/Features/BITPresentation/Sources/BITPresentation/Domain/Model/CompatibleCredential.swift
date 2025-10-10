import BITCredentialShared
import BITOpenID
import Foundation

public struct CompatibleCredential: Identifiable, Equatable {

  // MARK: Lifecycle

  public init(credential: VerifiableCredential, requestedFields: [PresentationField]) {
    self.credential = credential
    id = credential.id

    self.requestedFields = requestedFields
  }

  // MARK: Public

  public let id: UUID

  // MARK: Internal

  let credential: VerifiableCredential
  let requestedFields: [PresentationField]

  var requestedClusteredClaims: [CredentialClaimCluster] {
    credential.clusters.compactMap {
      filterClusterClaims($0, requestedFields: requestedFields)
    }
  }

  // MARK: Private

  private func filterClusterClaims(_ cluster: CredentialClaimCluster, requestedFields: [PresentationField]) -> CredentialClaimCluster? {
    let requestedClaims = cluster.claims.filter { claim in
      requestedFields.contains { $0.key == claim.key }
    }
    let requestedChildClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, requestedFields: requestedFields)
    }
    guard !requestedClaims.isEmpty || !requestedChildClusters.isEmpty else { return nil }
    return CredentialClaimCluster(id: cluster.id, order: cluster.order, claims: requestedClaims, childClusters: requestedChildClusters, displays: cluster.displays)
  }
}
