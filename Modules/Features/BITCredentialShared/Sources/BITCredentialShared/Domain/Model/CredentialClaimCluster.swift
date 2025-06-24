import BITCore
import BITEntities
import Foundation

// MARK: - CredentialClaimCluster

public struct CredentialClaimCluster: Codable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    order: Int = 0,
    claims: [CredentialClaim] = [],
    childClusters: [CredentialClaimCluster] = [],
    displays: [ClusterDisplay] = [])
  {
    self.id = id
    self.order = order
    self.claims = claims
    self.childClusters = childClusters
    self.displays = displays
  }

  public init(_ entity: CredentialClaimClusterEntity) {
    id = entity.id
    order = Int(entity.order)
    claims = Array(entity.claims.map(CredentialClaim.init))
    childClusters = Array(entity.childClusters.map(CredentialClaimCluster.init))
    displays = Array(entity.displays.map(ClusterDisplay.init))
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    order = try container.decode(Int.self, forKey: .order)
    claims = try container.decode([CredentialClaim].self, forKey: .claims)
    childClusters = try container.decode([CredentialClaimCluster].self, forKey: .childClusters)
    displays = try container.decode([ClusterDisplay].self, forKey: .displays)
  }

  // MARK: Public

  public var id: UUID
  public var order: Int
  public var claims: [CredentialClaim]
  public var childClusters: [CredentialClaimCluster]
  public var displays: [ClusterDisplay]

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case order
    case claims
    case childClusters = "child_clusters"
    case displays
  }

}

// MARK: Equatable

extension CredentialClaimCluster: Equatable {

  public static func == (lhs: CredentialClaimCluster, rhs: CredentialClaimCluster) -> Bool {
    lhs.id == rhs.id &&
      lhs.order == rhs.order &&
      lhs.claims.allSatisfy(rhs.claims.contains) && rhs.claims.allSatisfy(lhs.claims.contains) &&
      lhs.childClusters.allSatisfy(rhs.childClusters.contains) && rhs.childClusters.allSatisfy(lhs.childClusters.contains) &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains)
  }

}
