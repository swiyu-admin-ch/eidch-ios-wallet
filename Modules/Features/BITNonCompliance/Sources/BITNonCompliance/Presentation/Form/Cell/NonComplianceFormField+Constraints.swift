import BITL10n
import Factory

extension NonComplianceFormField {
  var maximumLength: Int? {
    switch self {
    case .description: Container.shared.descriptionFormFieldMaximumLength()
    case .email: nil
    }
  }

  var minimumLength: Int? {
    switch self {
    case .description: Container.shared.descriptionFormFieldMinimumLength()
    case .email: nil
    }
  }
}
