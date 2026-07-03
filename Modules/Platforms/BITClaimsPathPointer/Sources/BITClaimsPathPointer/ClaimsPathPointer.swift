import Foundation

public typealias ClaimsPathPointer = [ClaimsPathPointerElement]

// MARK: - ClaimsPathPointerElement

public enum ClaimsPathPointerElement: Codable, Hashable {
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

  public var allIndices: [Int] {
    compactMap { element in
      if case .index(let index) = element {
        return index
      }
      return nil
    }
  }

  public func pointsAtSetOf(_ otherPath: ClaimsPathPointer, enforceLength: Bool = false) -> Bool {
    if enforceLength {
      guard count == otherPath.count else { return false }
    } else {
      guard count <= otherPath.count else { return false }
    }

    for (component, otherComponent) in zip(self, otherPath) {
      if component != otherComponent {
        guard component == .null else { return false }
        guard case .index = otherComponent else { return false }
      }
    }

    return true
  }

  public func resolveNullElement(with indices: [Int]) -> ClaimsPathPointer {
    var indices = indices
    return map { element in
      if element == .null {
        guard let index = indices.first else { return element }
        let newElement = ClaimsPathPointerElement.index(index)
        indices = [Int](indices.dropFirst())
        return newElement
      }

      return element
    }
  }
}
