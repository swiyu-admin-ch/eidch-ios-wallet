import BITL10n
import Factory
import Foundation
import Spyable

// MARK: - NonComplianceFormValidatorProtocol

@Spyable
protocol NonComplianceFormValidatorProtocol {
  func validate(_ value: String, for field: NonComplianceFormField) -> NonComplianceFormFieldValidation
}

// MARK: - NonComplianceFormValidator

class NonComplianceFormValidator: NonComplianceFormValidatorProtocol {

  // MARK: Internal

  func validate(_ value: String, for field: NonComplianceFormField) -> NonComplianceFormFieldValidation {
    switch field {
    case .description: validateDescription(value)
    case .email: validateEmail(value)
    }
  }

  // MARK: Private

  private static let emailRegex = #/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/#

  @Injected(\.descriptionFormFieldMaximumLength) private var descriptionFormFieldMaximumLength
  @Injected(\.descriptionFormFieldMinimumLength) private var descriptionFormFieldMinimumLength

  private func validateDescription(_ value: String) -> NonComplianceFormFieldValidation {
    if value.count < descriptionFormFieldMinimumLength {
      .tooShort
    } else if value.count > descriptionFormFieldMaximumLength {
      .tooLong
    } else {
      .valid
    }
  }

  private func validateEmail(_ value: String) -> NonComplianceFormFieldValidation {
    if value.isEmpty || value.wholeMatch(of: Self.emailRegex) != nil {
      .valid
    } else {
      .malformed
    }
  }

}
