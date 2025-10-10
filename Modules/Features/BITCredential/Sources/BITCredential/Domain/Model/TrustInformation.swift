import BITJWT
import BITOpenID
import Foundation

// MARK: - TrustInformation

public struct TrustInformation: Equatable {
  public let identity: IdentityTrust
  public let vcSchema: VcSchemaTrust

  public init(identity: IdentityTrust, vcSchema: VcSchemaTrust) {
    self.identity = identity
    self.vcSchema = vcSchema
  }
}

// MARK: - IdentityTrust

public enum IdentityTrust: Equatable {
  case trusted(any LocalizedTrustStatement)
  case untrusted

  // MARK: Public

  public static func == (lhs: IdentityTrust, rhs: IdentityTrust) -> Bool {
    switch (lhs, rhs) {
    case (.untrusted, .untrusted):
      return true
    case (.trusted(let lhsStmt), .trusted(let rhsStmt)):
      if
        let lhsEquatable = lhsStmt as? MetadataTrustStatementPayload,
        let rhsEquatable = rhsStmt as? MetadataTrustStatementPayload
      {
        return lhsEquatable == rhsEquatable
      }
      if
        let lhsEquatable = lhsStmt as? IdentityTrustStatementPayload,
        let rhsEquatable = rhsStmt as? IdentityTrustStatementPayload
      {
        return lhsEquatable == rhsEquatable
      }
      return false
    default:
      return false
    }
  }
}
