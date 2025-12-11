import Foundation

public enum VcSchemaTrust: String, Codable, Equatable {
  case notProtected
  case trusted
  case untrusted
}
