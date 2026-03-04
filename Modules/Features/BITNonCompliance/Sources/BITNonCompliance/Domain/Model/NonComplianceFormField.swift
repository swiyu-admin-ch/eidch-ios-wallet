import Foundation

// MARK: - NonComplianceFormField

enum NonComplianceFormField: CaseIterable, Hashable {
  case description
  case email
}

extension NonComplianceFormField {
  static var mandatoryFields: [NonComplianceFormField] {
    [.description]
  }
}
