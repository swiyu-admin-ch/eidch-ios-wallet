import BITAppAuth
import BITCore
import BITL10n
import Combine
import Factory
import Foundation
import Spyable
import SwiftUI

// MARK: - PinCodeViewModel

@MainActor
class PinCodeViewModel: ObservableObject, Vibrating {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  var error: Error?
  @Published var isErrorPresented = false
  @Published var inputFieldMessage: String = L10n.tkOnboardingPasswordInputSubtitle

  // attempts allows us to have the ShakeEffect on the inputField
  @Published var attempts = 0

  @Injected(\.pinCodeErrorAuthHideDelay) var autoHideErrorDelay: Double

  @Published var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      do {
        try validatePinCodeRuleUseCase.execute(pinCode)
        inputFieldMessage = L10n.tkOnboardingPasswordInputSubtitle
      } catch {
        handleError(error)
      }
    }
  }

  func validate() {
    do {
      userDidRequestValidation = true
      pinCode = pinCode.trimmingCharacters(in: .whitespacesAndNewlines)
      try validatePinCodeRuleUseCase.execute(pinCode)
      router.context.pincode = pinCode
      reset()
      router.pinCodeConfirmation()
    } catch {
      withAnimation {
        attempts += 1
        vibrate()
        inputFieldMessage = error.localizedDescription
      }
    }
  }

  // MARK: Private

  private var userDidRequestValidation = false

  @Injected(\.validatePinCodeRuleUseCase) private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocol

  @Injected(\.pinCodeObserverDelay) private var pinCodeObserverDelay: CGFloat

  private weak var delegate: PinCodeDelegate?
  private let router: OnboardingInternalRoutes

  private func reset() {
    userDidRequestValidation = false
    pinCode = ""
    isErrorPresented = false
    error = nil
    inputFieldMessage = L10n.tkOnboardingPasswordInputSubtitle
    attempts = 0
  }

  private func handleError(_ error: Error) {
    inputFieldMessage = error.localizedDescription
  }

}

// MARK: - Haptic feedback

extension PinCodeViewModel {

  private func vibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
  }

}

// MARK: - PinCodeDelegate

@Spyable
public protocol PinCodeDelegate: AnyObject {
  func didTryTooManyAttempts()
}
