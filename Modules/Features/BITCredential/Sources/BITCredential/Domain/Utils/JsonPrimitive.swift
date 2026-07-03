import Foundation

enum JsonPrimitive {
  case string(String)
  case numeric(String)
  case bool(Bool)
  case null

  // MARK: Lifecycle

  init?(_ value: Any?) {
    guard let value else { return nil }

    switch value {
    case let string as String:
      self = .string(string)
    case let int as Int:
      self = .numeric(String(int))
    case let double as Double:
      self = .numeric(String(double))
    case let bool as Bool:
      self = .bool(bool)
    default:
      return nil
    }
  }

  // MARK: Internal

  var stringValue: String? {
    switch self {
    case .string(let string):
      string
    case .numeric(let number):
      number
    case .bool(let bool):
      String(bool)
    case .null:
      nil
    }
  }
}
