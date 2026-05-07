import Foundation

// MARK: - Disclosure

public enum Disclosure {
  case keyedElement(key: String, value: Any, disclosure: String)
  case arrayElement(value: Any, disclosure: String)
}
