import BITAppAuth
import BITL10n
import Combine
import Factory
import Foundation
import SwiftUI

// MARK: - PinCodeConfirmationViewModel

@MainActor
@Observable
public class PinCodeConfirmationViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
    originPinCode = router.context.pincode ?? ""
    delegate = router.context.pinCodeDelegate
  }

  // MARK: Internal

  let originPinCode: String

  var inputFieldMessage: String?
  var attempts = 0

  var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      do {
        try validatePinCodeRuleCompliance()
        inputFieldMessage = nil
      } catch {
        handleError(error)
      }
    }
  }

  func validate() {
    do {
      pinCode = pinCode.trimmingCharacters(in: .whitespacesAndNewlines)
      userDidRequestValidation = true
      try validatePinCodeRuleCompliance()
      reset()
      nextOnboardingStep()
    } catch {
      attempts += 1
      handleError(error)
    }
  }

  // MARK: Private

  private var userDidRequestValidation = false
  private let router: OnboardingInternalRoutes

  private weak var delegate: PinCodeDelegate?

  @ObservationIgnored @Injected(\.attemptsLimit) private var attemptsLimit: Int
  @ObservationIgnored @Injected(\.pinCodeObserverDelay) private var pinCodeObserverDelay: CGFloat

  @ObservationIgnored @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  @ObservationIgnored @Injected(\.validatePinCodeRuleUseCase) private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocol

  private var attemptLeft: Int {
    attemptsLimit - attempts
  }

  private func validatePinCodeRuleCompliance() throws {
    try validatePinCodeRuleUseCase(pinCode)
    guard pinCode == originPinCode else { throw PinCodeError.mismatch }
  }

  private func nextOnboardingStep() {
    reset()

    switch getBiometricStateUseCase() {
    case .declined,
         .notEnrolled:
      router.setup()
    case .disabled,
         .enabled:
      router.biometrics()
    }
  }

  private func reset() {
    userDidRequestValidation = false
    pinCode = ""
    attempts = 0
    inputFieldMessage = nil
  }

  private func handleError(_ error: Error) {
    if attemptLeft <= 0 {
      delegate?.didTryTooManyAttempts()
      router.pop()
      return
    }

    withAnimation {
      inputFieldMessage = "\(L10n.tkOnboardingPasswordConfirmationInputErrorWrongPassword) \(L10n.tkOnboardingPasswordConfirmationInputErrorNumberOfTriesLeft(attemptLeft))"
    }
  }

}
