import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct AVIntroSelfieVideoView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.selfie.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestAutoVerificationIntroSelfieVideoPrimary,
          secondary: L10n.tkEidRequestAutoVerificationIntroSelfieVideoSecondary)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: { navigator.navigate(to: EIDRequestDestinations.recordSelfie) })
      })
      .navigationBarBackButtonHidden(true)
      .toolbar { CloseButtonToolbar(action: { navigator.dismiss() }) }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

}

#Preview {
  AVIntroSelfieVideoView()
}
