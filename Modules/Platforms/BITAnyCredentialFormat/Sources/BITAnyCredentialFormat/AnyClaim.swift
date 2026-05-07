import BITClaimsPathPointer
import BITCore
import Foundation
import Spyable

// MARK: - AnyClaim

@Spyable
public protocol AnyClaim {
  var key: String { get }
  var path: ClaimsPathPointer { get }
  var value: CodableValue? { get }
}

extension AnyClaim {
  public func anyValue() throws -> Any {
    switch value {
    case .string(let stringValue): stringValue
    case .int(let intValue): intValue
    case .double(let doubleValue): doubleValue
    case .bool(let boolValue): boolValue
    case .array(let arrayValue): arrayValue
    case .dictionary(let dictionaryValue): dictionaryValue
    case .none: throw AnyClaimError.invalidValueType
    }
  }
}

// MARK: - AnyClaimError

fileprivate enum AnyClaimError: Error {
  case invalidValueType
}
