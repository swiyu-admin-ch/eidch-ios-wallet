import BITJWT
import BITNonCompliance
import BITOpenID
import Foundation

// MARK: - TrustInformation

public struct TrustInformation: Equatable {
  public let identity: IdentityTrust
  public let vcSchema: VcSchemaTrust
  public let actorCompliance: ActorCompliance?

  public init(identity: IdentityTrust, vcSchema: VcSchemaTrust, actorCompliance: ActorCompliance? = nil) {
    self.identity = identity
    self.vcSchema = vcSchema
    self.actorCompliance = actorCompliance
  }
}

// MARK: - IdentityTrust

public enum IdentityTrust: Equatable {
  case trusted(IdentityTrustStatementJWT)
  case untrusted
  case unknown
}
