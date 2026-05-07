import BITCore
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NewPinCodeViewModel

@Observable
class NewPinCodeViewModel: Vibrating {

  // MARK: Lifecycle

  init(router: ChangePinCodeInternalRoutes) {
    self.router = router
    self.router.context.newPinCodeDelegate = self
  }

  // MARK: Internal

  var router: ChangePinCodeInternalRoutes

  var inputFieldMessage: String = L10n.tkOnboardingCharactersSubtitle
  var inputFieldState = InputFieldState.normal
  var toast: Toast?

  var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      do {
        try validatePinCodeRuleUseCase.execute(pinCode)
        inputFieldState = .normal
        inputFieldMessage = L10n.tkOnboardingCharactersSubtitle
      } catch {
        handleError(error)
      }
    }
  }

  var isSubmitEnabled: Bool {
    pinCode.count >= pinCodeMinimumSize
  }

  func submit() {
    do {
      userDidRequestValidation = true
      try validatePinCodeRuleUseCase.execute(pinCode)
      inputFieldState = .normal
      router.context.newPinCode = pinCode
      router.confirmNewPinCode()
    } catch {
      vibrate()
      handleError(error)
    }
  }

  // MARK: Private

  private var userDidRequestValidation = false

  @ObservationIgnored @Injected(\.pinCodeMinimumSize) private var pinCodeMinimumSize: Int
  @ObservationIgnored @Injected(\.validatePinCodeRuleUseCase) private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocol

  private func handleError(_ error: Error) {
    withAnimation {
      inputFieldState = .error
      inputFieldMessage = error.localizedDescription
    }
  }

}

// MARK: NewPinCodeDelegate

extension NewPinCodeViewModel: NewPinCodeDelegate {
  func didFail() {
    toast = Toast(L10n.tkChangepasswordError4Notification, type: .error)
  }
}
