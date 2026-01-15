import BITCore
import Foundation

// MARK: - NonComplianceFormViewState

enum NonComplianceFormViewState: Equatable {
  case loading
  case result(Result)
  case error(NonComplianceFormViewModelError)
  case final

  struct Result: Equatable, Changeable {
    var actorImage: Data?
    var actorName: String?
    var isSendingEnabled: Bool
    var validations: [NonComplianceFormField: NonComplianceFormFieldValidation]
  }
}

#if DEBUG
extension NonComplianceFormViewState {
  struct Mock {
    static var resultValid: NonComplianceFormViewState {
      let viewState = NonComplianceFormViewState.Result(
        actorImage: nil,
        isSendingEnabled: true,
        validations: [:])
      return .result(viewState)
    }

    static var resultInvalid: NonComplianceFormViewState {
      let viewState = NonComplianceFormViewState.Result(
        actorImage: nil,
        isSendingEnabled: false,
        validations: [.description: .tooShort, .email: .malformed])
      return .result(viewState)
    }
  }
}
#endif
