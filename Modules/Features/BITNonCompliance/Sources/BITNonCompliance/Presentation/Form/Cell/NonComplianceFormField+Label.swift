import BITL10n

extension NonComplianceFormField {

  // MARK: Internal

  var placeholder: String {
    switch self {
    case .description: L10n.tkNonComplianceReportFormDescriptionPlaceholder
    case .email: L10n.tkNonComplianceReportFormContactPlaceholder
    }
  }

  var title: String {
    switch self {
    case .description: L10n.tkNonComplianceReportFormDescriptionTitle
    case .email: L10n.tkNonComplianceReportFormContactTitle
    }
  }

  var titleAlt: String {
    switch self {
    case .description: L10n.tkNonComplianceReportFormDescriptionTitleAlt
    case .email: L10n.tkNonComplianceReportFormContactTitle
    }
  }

  func hint(for validation: NonComplianceFormFieldValidation?) -> String? {
    switch self {
    case .description: descriptionHint(for: validation)
    case .email: validation == .valid ? nil : L10n.tkNonComplianceReportFormContactValidation
    }
  }

  // MARK: Private

  private func descriptionHint(for validation: NonComplianceFormFieldValidation?) -> String? {
    switch validation {
    case .tooShort,
         .valid: L10n.tkNonComplianceReportFormDescriptionFooter
    case .tooLong: L10n.tkNonComplianceReportFormDescriptionMaxCharacterFooter
    case .malformed,
         .none: nil
    }
  }
}
