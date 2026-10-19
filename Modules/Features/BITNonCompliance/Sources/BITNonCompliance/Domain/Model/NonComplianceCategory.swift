import Foundation

#warning("More categories added in upcoming stories")
public enum NonComplianceCategory: String, Identifiable, CaseIterable, Codable, Sendable {
  case excessiveDataRequest = "ExcessiveDataRequest"

  public var id: String {
    rawValue
  }
}
