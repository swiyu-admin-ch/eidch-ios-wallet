import BITClaimsPathPointer
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
    path: ClaimsPathPointer = [],
    order: Int = 0,
    isSensitive: Bool = false,
    claims: [CredentialClaim] = [],
    childClusters: [CredentialClaimCluster] = [],
    displays: [ClusterDisplay] = [])
  {
    self.id = id
    self.path = path
    self.order = order
    self.isSensitive = isSensitive
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
      path: ClaimsPathPointer(entity.path) ?? [],
      order: Int(entity.order),
      isSensitive: entity.isSensitive,
      claims: claims,
      childClusters: childClusters,
      displays: displays)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(UUID.self, forKey: .id)
    let path = try container.decode(ClaimsPathPointer.self, forKey: .path)
    let order = try container.decode(Int.self, forKey: .order)
    let isSensitive = try container.decode(Bool.self, forKey: .isSensitive)
    let claims = try container.decode([CredentialClaim].self, forKey: .claims)
    let childClusters = try container.decode([CredentialClaimCluster].self, forKey: .childClusters)
    let displays = try container.decode([ClusterDisplay].self, forKey: .displays)
    self.init(id: id, path: path, order: order, isSensitive: isSensitive, claims: claims, childClusters: childClusters, displays: displays)
  }

  // MARK: Public

  public var id: UUID
  public var path: ClaimsPathPointer
  public var order: Int
  public var isSensitive: Bool
  public var claims: [CredentialClaim]
  public var childClusters: [CredentialClaimCluster]
  public var displays: [ClusterDisplay]
  public var preferredDisplay: ClusterDisplay?

  public var items: [ClusterItem] {
    let items: [ClusterItem] = claims + childClusters
    return items.sorted { $0.order < $1.order }
  }

  public var isSimpleArray: Bool {
    if case .null = path.last, childClusters.isEmpty {
      return true
    }
    return false
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case path
    case order
    case isSensitive = "is_sensitive"
    case claims
    case childClusters = "child_clusters"
    case displays
  }

}

// MARK: Equatable

extension CredentialClaimCluster: Equatable {

  public static func == (lhs: CredentialClaimCluster, rhs: CredentialClaimCluster) -> Bool {
    lhs.id == rhs.id &&
      lhs.path == rhs.path &&
      lhs.order == rhs.order &&
      lhs.isSensitive == rhs.isSensitive &&
      lhs.claims.allSatisfy(rhs.claims.contains) && rhs.claims.allSatisfy(lhs.claims.contains) &&
      lhs.childClusters.allSatisfy(rhs.childClusters.contains) && rhs.childClusters.allSatisfy(lhs.childClusters.contains) &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains)
  }

}
