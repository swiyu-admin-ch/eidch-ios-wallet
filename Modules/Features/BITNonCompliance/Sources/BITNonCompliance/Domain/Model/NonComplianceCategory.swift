import Foundation

#warning("More categories added in upcoming stories")
public enum NonComplianceCategory: String, Identifiable, CaseIterable, Codable {
  case excessiveDataRequest = "ExcessiveDataRequest"

  public var id: String { rawValue }
}
