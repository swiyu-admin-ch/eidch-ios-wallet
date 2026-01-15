import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct DataPrivacyView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.shield.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestDataPrivacyTitle,
          secondary: L10n.tkEidRequestDataPrivacyBody,
          tertiary: L10n.tkEidRequestDataPrivacyLinkText,
          tertiaryAction: { openLink(L10n.tkEidRequestDataPrivacyLinkValue) })
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestDataPrivacyPrimaryButton,
          primaryButtonAction: { navigator.navigate(to: EIDRequestDestinations.attestation) })
      })
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @Environment(\.openURL) private var openURL

  private func openLink(_ link: String) {
    guard let url = URL(string: link) else { return }
    openURL(url)
  }
}

#Preview {
  DataPrivacyView()
}
