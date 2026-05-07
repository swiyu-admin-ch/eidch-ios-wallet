import Factory
import SwiftUI

// MARK: - NonComplianceDescriptionViewModel

@Observable
class NonComplianceDescriptionViewModel {

  // MARK: Lifecycle

  init(initialValue: String) {
    value = ""
    defer {
      value = initialValue // triggers didSet
    }
  }

  // MARK: Internal

  private(set) var validation = NonComplianceFormFieldValidation.valid

  var value: String {
    didSet {
      validation = nonComplianceFormValidator.validate(value, for: .description)
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.nonComplianceFormValidator) private var nonComplianceFormValidator

}
