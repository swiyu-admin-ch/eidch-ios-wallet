import NavigatorUI

// MARK: - NonComplianceCheckpoints

struct NonComplianceCheckpoints: NavigationCheckpoints {
  static var form: NavigationCheckpoint<NonComplianceFormCheckpointUpdate> {
    checkpoint()
  }
}

// MARK: - NonComplianceFormCheckpointUpdate

struct NonComplianceFormCheckpointUpdate: Hashable {
  let field: NonComplianceFormField
  let value: String
}
