import BITL10n
import BITTheming
import SwiftUI

struct CompletionView: View {

  let router: OnboardingInternalRoutes

  var body: some View {
    InformationView(
      image: Assets.checkmarkCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkOnboardingDonePrimary,
          secondary: L10n.tkOnboardingDoneSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: {
            router.context.onboardingDelegate?.didCompleteOnboarding()
          })
      })
      .navigationBarBackButtonHidden()
  }
}
