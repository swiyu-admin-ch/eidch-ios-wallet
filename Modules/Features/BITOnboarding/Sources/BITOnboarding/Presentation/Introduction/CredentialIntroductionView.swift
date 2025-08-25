import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - CredentialIntroductionView

struct CredentialIntroductionView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    viewModel = Container.shared.credentialIntroductionViewModel(router)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialIntroductionContent"
  }

  var body: some View {
    InformationView(
      image: Assets.eId.swiftUIImage,
      backgroundImage: ThemingAssets.Gradient.gradient5.swiftUIImage,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkOnboardingIntroductionStepNeverForgetPrimary,
          secondary: L10n.tkOnboardingIntroductionStepNeverForgetSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: viewModel.primaryAction)
      })
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private let viewModel: CredentialIntroductionViewModel

}

// MARK: - CredentialIntroductionViewModel

class CredentialIntroductionViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  let router: OnboardingInternalRoutes

  func primaryAction() {
    router.privacyPermission()
  }

}
