import BITAnyCredentialFormat
import BITCore
import Foundation

public struct OtherMockAnyCredential: AnyCredential {

  public var format = "unknown_format"

  public var raw: String {
    "mock value"
  }

  public var claims: [any AnyClaim] {
    []
  }

  public var issuer: String {
    ""
  }

  public var status: (any BITAnyCredentialFormat.AnyStatus)? {
    nil
  }

  public var validFrom: Date? {
    nil
  }

  public var validUntil: Date? {
    nil
  }

  public var vcSchemaId: String {
    "vcSchemaId"
  }

  public func getClaimsDictionary(_ claimSet: BITAnyCredentialFormat.ClaimKind) -> [String: Any?] {
    [:]
  }
}
