import BITEntities
import Foundation

// MARK: - ActivityClaim

public struct ActivityClaim: Codable {

  // MARK: Lifecycle

  public init(credentialClaimId: UUID) {
    self.credentialClaimId = credentialClaimId
  }

  public init(_ entity: ActivityClaimEntity) {
    self.init(credentialClaimId: entity.credentialClaimId)
  }

  // MARK: Public

  public var credentialClaimId: UUID
}

// MARK: Equatable

extension ActivityClaim: Equatable {

}
