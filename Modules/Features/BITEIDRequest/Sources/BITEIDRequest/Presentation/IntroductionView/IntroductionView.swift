import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct IntroductionView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.card.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestIntroTitle,
          secondary: L10n.tkEidRequestIntroBody,
          tertiary: L10n.tkEidRequestIntroSmallBody)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestIntroPrimaryButton,
          primaryButtonAction: { navigator.navigate(to: EIDRequestDestinations.dataPrivacyView) },
          secondaryButtonLabel: L10n.tkEidRequestIntroSecondaryButton,
          secondaryButtonAction: { navigator.dismiss() })
      })
      .toolbar {
        CloseButtonToolbar(action: {
          navigator.dismiss()
        })
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator: Navigator
}

#Preview {
  IntroductionView()
}
