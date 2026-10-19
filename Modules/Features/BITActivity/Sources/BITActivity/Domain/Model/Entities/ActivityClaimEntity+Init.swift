import BITEntities
import Foundation

extension ActivityClaimEntity {

  public convenience init(_ claim: ActivityClaim) {
    self.init()
    path = claim.path
  }
}
