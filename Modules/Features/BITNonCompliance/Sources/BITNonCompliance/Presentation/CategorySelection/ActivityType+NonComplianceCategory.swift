import BITActivity

extension ActivityType {
  var nonComplianceCategories: [NonComplianceCategory] {
    switch self {
    case .issuance: []
    case .presentationAccepted,
         .presentationDeclined: [.excessiveDataRequest]
    }
  }
}
