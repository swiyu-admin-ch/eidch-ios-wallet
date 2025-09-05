import BITCore
import BITL10n
import Factory
import Foundation
import SwiftUI

// MARK: - ConfirmPinCodeViewModel

@MainActor
public class ConfirmPinCodeViewModel: ObservableObject, Vibrating {

  // MARK: Lifecycle

  init(router: ChangePinCodeInternalRoutes) {
    self.router = router
    originPinCode = router.context.newPinCode ?? ""
  }

  // MARK: Internal

  @Published var inputFieldMessage: String?
  @Published var attempts = 0
  @Published var inputFieldState = InputFieldState.normal

  @Published var pinCode = "" {
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

  @Injected(\.attemptsLimitChangePinCode) private var attemptsLimit: Int
  @Injected(\.pinCodeObserverDelay) private var pinCodeObserverDelay: CGFloat

  @Injected(\.updatePinCodeUseCase) private var updatePinCode: UpdatePinCodeUseCaseProtocol
  @Injected(\.validatePinCodeRuleUseCase) private var validatePinCode: ValidatePinCodeRuleUseCaseProtocol

  private var attemptLeft: Int { attemptsLimit - attempts }

  private func validatePinCodeRuleCompliance() throws {
    try validatePinCode.execute(pinCode)
    guard pinCode == originPinCode else { throw PinCodeError.mismatch }
  }

  private func closeFlow() {
    router.context.changePinCodeDelegate?.didChangePinCode()
    // 4 because we have 3 steps in the change flow and we want to go back on the 4th screen aka Settings
    router.pop(number: 4)
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
