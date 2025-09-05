import Foundation

// MARK: - MRZError

public enum MRZError: Error, LocalizedError {
  case malformed(reason: String)
  case invalidLineCount(actual: Int)

  public var errorDescription: String? {
    switch self {
    case .malformed(let reason):
      "MRZ is malformed: \(reason)"
    case .invalidLineCount(let actual):
      "Invalid MRZ line count. Received \(actual)"
    }
  }
}

// MARK: - MRZ

public struct MRZ: Equatable {

  // MARK: Lifecycle

  public init(values: [String]) throws {
    let processedValues = Self.processRawValues(values)
    try Self.validate(processedValues)

    self.values = processedValues
  }

  // MARK: Public

  public var values: [String]

  // MARK: Private

  private static func processRawValues(_ values: [String]) -> [String] {
    values.map { $0.replacingOccurrences(of: "*", with: "<") }
  }

  private static func validate(_ values: [String]) throws {
    guard [2, 3].contains(values.count) else {
      throw MRZError.invalidLineCount(actual: values.count)
    }

    for (index, value) in values.enumerated() {
      if value.isEmpty {
        throw MRZError.malformed(reason: "Line \(index + 1) is empty")
      }
    }
  }
}

// MARK: CustomStringConvertible

extension MRZ: CustomStringConvertible {
  public var description: String {
    values.joined(separator: "\n")
  }
}
