import BITJWT
import BITOpenID
import Foundation

// MARK: - TrustInformation

public struct TrustInformation: Equatable, Hashable {
  public let identity: IdentityTrust
  public let vcSchema: VcSchemaTrust

  public init(identity: IdentityTrust, vcSchema: VcSchemaTrust) {
    self.identity = identity
    self.vcSchema = vcSchema
  }
}

// MARK: - IdentityTrust

public enum IdentityTrust: Equatable, Hashable {
  case trusted
  case untrusted
  case unknown
  case trustedCheckApp
}
