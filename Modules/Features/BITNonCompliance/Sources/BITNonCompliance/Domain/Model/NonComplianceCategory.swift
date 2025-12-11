import Foundation

#warning("More categories added in upcoming stories")
public enum NonComplianceCategory: Int, Identifiable, CaseIterable {
  case excessiveDataRequest

  public var id: Int { rawValue }
}
