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
@Observable
class PinCodeViewModel: Vibrating {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  var error: Error?
  var isErrorPresented = false
  var inputFieldMessage: String = L10n.tkOnboardingPasswordInputSubtitle

  /// attempts allows us to have the ShakeEffect on the inputField
  var attempts = 0

  @ObservationIgnored @Injected(\.pinCodeErrorAuthHideDelay) var autoHideErrorDelay: Double

  var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      do {
        try validatePinCodeRuleUseCase(pinCode)
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
      try validatePinCodeRuleUseCase(pinCode)
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

  @ObservationIgnored @Injected(\.validatePinCodeRuleUseCase) private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocol

  @ObservationIgnored @Injected(\.pinCodeObserverDelay) private var pinCodeObserverDelay: CGFloat

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
