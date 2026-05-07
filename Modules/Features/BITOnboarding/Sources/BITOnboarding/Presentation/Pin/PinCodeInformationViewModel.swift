import BITL10n
import BITTheming
import Foundation
import SwiftUI

// MARK: - PinCodeInformationViewModel

@Observable
class PinCodeInformationViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  var primaryText: String = L10n.tkOnboardingPasswordIntroductionPrimary
  var secondaryText: String = L10n.tkOnboardingPasswordIntroductionSecondary
  let image: Image = Assets.lock.swiftUIImage
  let backgroundImage: Image = ThemingAssets.Gradient.gradient8.swiftUIImage
  let buttonLabelText: String = L10n.tkOnboardingPasswordIntroductionButtonPrimary

  func nextOnboardingStep() {
    router.context.pinCodeDelegate = self
    router.pinCode()
  }

  func onAppear() {
    if hasTooManyAttemptsBeingTried {
      hasTooManyAttemptsBeingTried = false
      return
    }
    resetTexts()
  }

  // MARK: Private

  private var hasTooManyAttemptsBeingTried = false

  private let router: OnboardingInternalRoutes

  private func resetTexts() {
    secondaryText = L10n.tkOnboardingPasswordIntroductionSecondary
  }

}

// MARK: PinCodeDelegate

extension PinCodeInformationViewModel: PinCodeDelegate {
  func didTryTooManyAttempts() {
    secondaryText = L10n.tkOnboardingPasswordIntroductionErrorTooManyAttempts
    hasTooManyAttemptsBeingTried = true
  }
}
