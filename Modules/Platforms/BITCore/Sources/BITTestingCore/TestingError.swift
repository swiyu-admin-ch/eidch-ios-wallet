import Foundation

// MARK: - TestingError

public enum TestingError: Error {
  case error
}

// MARK: CustomStringConvertible

extension TestingError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .error: "error"
    }
  }
}
