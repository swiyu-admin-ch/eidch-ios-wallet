import BITClaimsPathPointer
import BITCore
import Foundation

// MARK: - SdJWTClaimError

enum SdJWTClaimError: Error {
  case invalidValueType
}

// MARK: - SdJWTClaim

public struct SdJWTClaim: Equatable {

  // MARK: Lifecycle

  public init(
    key: String,
    path: ClaimsPathPointer,
    value: Any,
    disclosure: String,
    digest: SdJwtDigest) throws
  {
    self.key = key
    self.path = path
    self.digest = digest
    self.disclosure = disclosure
    self.value = try CodableValue(anyValue: value)
  }

  // MARK: Public

  public let digest: SdJwtDigest
  public let key: String
  public let path: ClaimsPathPointer
  public var value: CodableValue?
  public let disclosure: String
}

extension SdJWTClaim {
  public func anyValue() throws -> Any {
    switch value {
    case .string(let stringValue): stringValue
    case .int(let intValue): intValue
    case .double(let doubleValue): doubleValue
    case .bool(let boolValue): boolValue
    case .array(let arrayValue): arrayValue
    case .dictionary(let dictionaryValue): dictionaryValue
    case .none: throw SdJWTClaimError.invalidValueType
    }
  }
}
