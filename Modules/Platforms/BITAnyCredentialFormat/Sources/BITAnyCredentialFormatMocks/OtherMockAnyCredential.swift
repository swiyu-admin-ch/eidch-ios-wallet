import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITCore
import Foundation

public struct OtherMockAnyCredential: AnyCredential {

  public var format = "unknown_format"

  public var raw: String {
    "mock value"
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

  public func getClaimsJSON(_ claimSet: BITAnyCredentialFormat.ClaimKind) -> JSON {
    [:]
  }

  public func getPresentingPaths(for paths: [ClaimsPathPointer]) -> [ClaimsPathPointer] {
    []
  }
}
