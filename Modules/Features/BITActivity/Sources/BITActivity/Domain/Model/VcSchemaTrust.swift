import Foundation

public enum VcSchemaTrust: String, Codable, Equatable, Sendable {
  case notProtected
  case trusted
  case untrusted
}
