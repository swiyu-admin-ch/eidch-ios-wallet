import BITEntities
import Foundation

// MARK: - ActivityClaim

public struct ActivityClaim: Codable, Sendable {

  // MARK: Lifecycle

  public init(path: String) {
    self.path = path
  }

  public init(_ entity: ActivityClaimEntity) {
    self.init(path: entity.path)
  }

  // MARK: Public

  public var path: String
}

// MARK: Equatable

extension ActivityClaim: Equatable {

}
