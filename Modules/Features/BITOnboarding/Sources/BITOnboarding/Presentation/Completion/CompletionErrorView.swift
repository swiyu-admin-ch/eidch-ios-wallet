import BITL10n
import BITTheming
import Foundation
import SwiftUI

// MARK: - CompletionErrorView

struct CompletionErrorView: View {

  let router: OnboardingInternalRoutes
  weak var delegate: SetupDelegate?

  var body: some View {
    InformationView(
      image: Assets.xmarkCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkOnboardingDoneErrorPrimary,
          secondary: L10n.tkOnboardingDoneErrorSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkOnboardingDoneErrorButtonPrimary,
          primaryButtonAction: {
            delegate?.restartSetup()
            router.pop()
          })
      })
      .navigationBarBackButtonHidden()
  }
}
