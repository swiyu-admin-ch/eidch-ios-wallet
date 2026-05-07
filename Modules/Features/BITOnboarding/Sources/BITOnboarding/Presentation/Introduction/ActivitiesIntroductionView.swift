import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - ActivitiesIntroductionView

struct ActivitiesIntroductionView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "activitiesIntroductionContent"
  }

  var body: some View {
    InformationView(
      image: Assets.history.swiftUIImage,
      backgroundImage: ThemingAssets.Gradient.gradient6.swiftUIImage,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkOnboardingIntroductionStepActivitiesPrimary,
          secondary: L10n.tkOnboardingIntroductionStepActivitiesSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: { router.infoScreenCredential() })
      })
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private let router: OnboardingInternalRoutes
}
