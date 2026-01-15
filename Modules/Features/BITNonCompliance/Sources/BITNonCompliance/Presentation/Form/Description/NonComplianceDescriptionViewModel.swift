import Factory
import SwiftUI

// MARK: - NonComplianceDescriptionViewModel

class NonComplianceDescriptionViewModel: ObservableObject {

  // MARK: Lifecycle

  init(initialValue: String) {
    value = ""
    defer {
      value = initialValue // triggers didSet
    }
  }

  // MARK: Internal

  @Published private(set) var validation = NonComplianceFormFieldValidation.valid

  @Published var value: String {
    didSet {
      validation = nonComplianceFormValidator.validate(value, for: .description)
    }
  }

  // MARK: Private

  @Injected(\.nonComplianceFormValidator) private var nonComplianceFormValidator

}
