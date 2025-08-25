import BITCore
import BITEntities
import Foundation

// MARK: - ClusterItem

public protocol ClusterItem {
  var id: UUID { get }
  var order: Int { get }
}

// MARK: - CredentialClaimCluster

public struct CredentialClaimCluster: Codable, ClusterItem {

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
    preferredDisplay = displays.findDisplayWithFallback()
  }

  public init(_ entity: CredentialClaimClusterEntity) {
    let claims = Array(entity.claims.map(CredentialClaim.init))
    let childClusters = Array(entity.childClusters.map(CredentialClaimCluster.init))
    let displays = Array(entity.displays.map(ClusterDisplay.init))
    self.init(
      id: entity.id,
      order: Int(entity.order),
      claims: claims,
      childClusters: childClusters,
      displays: displays)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(UUID.self, forKey: .id)
    let order = try container.decode(Int.self, forKey: .order)
    let claims = try container.decode([CredentialClaim].self, forKey: .claims)
    let childClusters = try container.decode([CredentialClaimCluster].self, forKey: .childClusters)
    let displays = try container.decode([ClusterDisplay].self, forKey: .displays)
    self.init(id: id, order: order, claims: claims, childClusters: childClusters, displays: displays)
  }

  // MARK: Public

  public var id: UUID
  public var order: Int
  public var claims: [CredentialClaim]
  public var childClusters: [CredentialClaimCluster]
  public var displays: [ClusterDisplay]
  public var preferredDisplay: ClusterDisplay?

  public var items: [ClusterItem] {
    let items: [ClusterItem] = claims + childClusters
    return items.sorted { $0.order < $1.order }
  }

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
