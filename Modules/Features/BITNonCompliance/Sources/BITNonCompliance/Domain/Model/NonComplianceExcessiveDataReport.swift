import BITActivity
import BITCredentialShared
import BITOpenID

// MARK: - NonComplianceExcessiveDataReport

struct NonComplianceExcessiveDataReport: NonComplianceReport {
  let category = NonComplianceCategory.excessiveDataRequest

  let description: String
  let email: String?
  let activity: Activity
  let credential: VerifiableCredential
}

// MARK: Equatable

extension NonComplianceExcessiveDataReport: Equatable {
  static func == (lhs: NonComplianceExcessiveDataReport, rhs: NonComplianceExcessiveDataReport) -> Bool {
    lhs.description == rhs.description
      && lhs.email == rhs.email
      && lhs.activity == rhs.activity
      && lhs.credential == rhs.credential
  }
}
