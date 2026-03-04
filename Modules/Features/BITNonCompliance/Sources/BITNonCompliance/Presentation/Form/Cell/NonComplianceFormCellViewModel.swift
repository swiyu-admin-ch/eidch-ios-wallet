import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NonComplianceFormCellViewModel

struct NonComplianceFormCellViewModel {

  // MARK: Internal

  let field: NonComplianceFormField
  let value: Binding<String>
  let validation: NonComplianceFormFieldValidation?

  var isInvalid: Bool {
    validation != nil && validation != .valid
  }

  var fieldText: String {
    let currentValue = value.wrappedValue
    return currentValue.isEmpty ? field.placeholder : currentValue
  }
}
