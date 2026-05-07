import Foundation

// MARK: - NonComplianceExcessiveDataReport

struct NonComplianceExcessiveDataReport: NonComplianceReport, Equatable {
  let category = NonComplianceCategory.excessiveDataRequest

  let description: String
  let email: String?
  let activity: NonComplianceActivity
}
