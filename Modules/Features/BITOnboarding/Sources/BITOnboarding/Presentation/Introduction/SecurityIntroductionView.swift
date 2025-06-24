import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - SecurityIntroductionView

struct SecurityIntroductionView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    viewModel = Container.shared.securityIntroductionViewModel(router)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case securityIntroductionContent
  }

  var body: some View {
    InformationView(
      image: Assets.shieldPerson.swiftUIImage,
      backgroundImage: ThemingAssets.Gradient.gradient7.swiftUIImage,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkOnboardingIntroductionStepYourDataPrimary,
          secondary: L10n.tkOnboardingIntroductionStepYourDataSecondary,
          tertiary: L10n.tkOnboardingIntroductionStepYourDataTertiaryLinkText,
          tertiaryAction: viewModel.secondaryAction)
          .accessibilityIdentifier(AccessibilityIdentifier.securityIntroductionContent.rawValue)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: viewModel.primaryAction)
      })
  }

  // MARK: Private

  private let viewModel: SecurityIntroductionViewModel

}

// MARK: - SecurityIntroductionViewModel

class SecurityIntroductionViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  let router: OnboardingInternalRoutes

  func secondaryAction() {
    guard let url = URL(string: L10n.tkOnboardingIntroductionStepYourDataTertiaryLinkValue) else { return }
    router.openExternalLink(url: url)
  }

  func primaryAction() {
    router.infoScreenCredential()
  }

}
