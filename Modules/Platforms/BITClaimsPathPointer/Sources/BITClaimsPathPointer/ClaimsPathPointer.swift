import Foundation

public typealias ClaimsPathPointer = [ClaimsPathPointerElement]

// MARK: - ClaimsPathPointerElement

public enum ClaimsPathPointerElement: Codable {
  case string(String)
  case index(Int)
  case null

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let index = try? container.decode(Int.self), index >= 0 {
      self = .index(index)
    } else if container.decodeNil() {
      self = .null
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid claim path element. Must be string, non-negative integer, or null.")
    }
  }

  // MARK: Public

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let string):
      try container.encode(string)
    case .index(let index):
      try container.encode(index)
    case .null:
      try container.encodeNil()
    }
  }
}

// MARK: Equatable

extension ClaimsPathPointerElement: Equatable {
  public static func == (lhs: ClaimsPathPointerElement, rhs: ClaimsPathPointerElement) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhsString), .string(let rhsString)):
      lhsString == rhsString
    case (.index(let lhsIndex), .index(let rhsIndex)):
      lhsIndex == rhsIndex
    case (.null, .null):
      true
    default:
      false
    }
  }
}

extension ClaimsPathPointer {

  // MARK: Lifecycle

  public init?(_ string: String) {
    let data = Data(string.utf8)
    if let pointer = try? JSONDecoder().decode(ClaimsPathPointer.self, from: data) {
      self = pointer
      return
    }
    return nil
  }

  // MARK: Public

  public var stringValue: String {
    let raw: [Any] = map { element in
      switch element {
      case .string(let s): s
      case .index(let i): i
      case .null: NSNull()
      }
    }

    let data = (try? JSONSerialization.data(withJSONObject: raw, options: [])) ?? Data()
    return String(decoding: data, as: UTF8.self)
  }

  public func isPointing(at otherPath: ClaimsPathPointer) -> Bool {
    for (index, component) in enumerated() {
      let otherComponent = otherPath[index]
      if component == .null && component != otherComponent {
        guard case .index = otherComponent else { return false }
      } else {
        guard otherComponent == component else { return false }
      }
    }
    return true
  }
}
