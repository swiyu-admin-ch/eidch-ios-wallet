import BITCore
import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - CompatibleCredential

public struct CompatibleCredential: Identifiable, Equatable {

  // MARK: Lifecycle

  public init(credential: VerifiableCredential, requestedFields: [PresentationField], dcqlQueryId: String? = nil) {
    self.credential = credential
    id = credential.id

    self.requestedFields = requestedFields
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
    credential.clusters.compactMap {
      filterClusterClaims($0, requestedFields: requestedFields)
    }
  }

  // MARK: Internal

  let requestedFields: [PresentationField]

  // MARK: Private

  private func filterClusterClaims(_ cluster: CredentialClaimCluster, requestedFields: [PresentationField]) -> CredentialClaimCluster? {
    #warning("TODO: Array / Object claim support")
    let requestedClaims = cluster.claims.filter { claim in
      matchRequestedClaim(claim, requestedFields: requestedFields)
    }
    let requestedChildClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, requestedFields: requestedFields)
    }
    guard !requestedClaims.isEmpty || !requestedChildClusters.isEmpty else { return nil }
    return CredentialClaimCluster(id: cluster.id, order: cluster.order, claims: requestedClaims, childClusters: requestedChildClusters, displays: cluster.displays)
  }

  private func matchRequestedClaim(_ claim: CredentialClaim, requestedFields: [PresentationField]) -> Bool {
    requestedFields.contains { field in
      if let pathPointer = field.pathPointer {
        return pathPointer == claim.path
      }
      guard let lastPathElement = claim.path.last, case .string(let key) = lastPathElement else {
        return false
      }
      return key == field.key
    }
  }
}
