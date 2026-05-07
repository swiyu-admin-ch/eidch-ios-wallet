import BITCore
import BITL10n
import Factory
import Foundation
import SwiftUI

// MARK: - ConfirmPinCodeViewModel

@MainActor
@Observable
public class ConfirmPinCodeViewModel: Vibrating {

  // MARK: Lifecycle

  init(router: ChangePinCodeInternalRoutes) {
    self.router = router
    originPinCode = router.context.newPinCode ?? ""
  }

  // MARK: Internal

  var inputFieldMessage: String?
  var attempts = 0
  var inputFieldState = InputFieldState.normal

  var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      do {
        try validatePinCodeRuleCompliance()
        inputFieldState = .normal
        inputFieldMessage = nil
      } catch {
        handleError(error)
      }
    }
  }

  func submit() {
    do {
      pinCode = pinCode.trimmingCharacters(in: .whitespacesAndNewlines)
      userDidRequestValidation = true
      try validatePinCodeRuleCompliance()
      guard let uniquePassphrase = router.context.uniquePassphrase else { throw AuthError.missingUniquePassphrase }
      try updatePinCode.execute(with: pinCode, and: uniquePassphrase)
      reset()
      closeFlow()
    } catch {
      attempts += 1
      vibrate()
      handleError(error)
    }
  }

  // MARK: Private

  private let originPinCode: String

  private var userDidRequestValidation = false
  private let router: ChangePinCodeInternalRoutes

  @ObservationIgnored @Injected(\.attemptsLimitChangePinCode) private var attemptsLimit: Int
  @ObservationIgnored @Injected(\.pinCodeObserverDelay) private var pinCodeObserverDelay: CGFloat

  @ObservationIgnored @Injected(\.updatePinCodeUseCase) private var updatePinCode: UpdatePinCodeUseCaseProtocol
  @ObservationIgnored @Injected(\.validatePinCodeRuleUseCase) private var validatePinCode: ValidatePinCodeRuleUseCaseProtocol

  private var attemptLeft: Int {
    attemptsLimit - attempts
  }

  private func validatePinCodeRuleCompliance() throws {
    try validatePinCode.execute(pinCode)
    guard pinCode == originPinCode else { throw PinCodeError.mismatch }
  }

  private func closeFlow() {
    router.context.changePinCodeDelegate?.didChangePinCode()
    // back to settings
    router.pop(count: 3)
  }

  private func reset() {
    userDidRequestValidation = false
    pinCode = ""
    attempts = 0
    inputFieldMessage = nil
  }

  private func handleError(_ error: Error) {
    if attemptLeft <= 0 {
      router.context.newPinCodeDelegate?.didFail()
      router.pop()
      return
    }

    withAnimation {
      inputFieldState = .error
      inputFieldMessage = L10n.tkChangepasswordError1Note2(attemptLeft)
    }
  }

}
