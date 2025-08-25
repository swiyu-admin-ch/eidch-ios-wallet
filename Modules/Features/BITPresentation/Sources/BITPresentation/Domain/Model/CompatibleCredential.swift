import BITCore
import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - CompatibleCredential

public struct CompatibleCredential: Identifiable {

  // MARK: Lifecycle

  public init(credential: Credential, requestedFields: [PresentationField]) {
    self.credential = credential
    id = credential.id

    self.requestedFields = requestedFields
  }

  // MARK: Public

  public let id: UUID

  public var requestedClusteredClaims: [CredentialClaimCluster] {
    credential.clusters.compactMap {
      filterClusterClaims($0, requestedFields: requestedFields)
    }
  }

  // MARK: Internal

  let credential: Credential
  let requestedFields: [PresentationField]

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

// MARK: Equatable

extension CompatibleCredential: Equatable {}

#if DEBUG
extension CompatibleCredential {
  struct Mock {
    static let array: [CompatibleCredential] = [BIT, diploma]
    static let fieldFirstName = PresentationField(jsonPath: "$.firstName", value: CodableValue(value: "Fritz", as: "string"))
    static let fieldLastName = PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "Test", as: "string"))

    // swiftlint: disable all
    static var BIT: CompatibleCredential { .init(credential: .Mock.sample, requestedFields: [fieldFirstName, fieldLastName]) }
    static var BITWithoutKeyBinding: CompatibleCredential { .init(credential: .Mock.sampleWithoutKeyBinding, requestedFields: [fieldFirstName, fieldLastName]) }
    static var diploma: CompatibleCredential { .init(credential: .Mock.diploma, requestedFields: [PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "lastName", as: "string"))]) }
    // swiftlint: enable all
  }
}
#endif
