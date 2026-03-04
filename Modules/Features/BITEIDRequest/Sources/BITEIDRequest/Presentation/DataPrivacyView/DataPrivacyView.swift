import BITL10n
import BITTheming
import SwiftUI

struct DataPrivacyView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.shield.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestDataPrivacyTitle, identifier: "primaryText"),
        .body(L10n.tkEidRequestDataPrivacyBody, identifier: "secondaryText"),
        .captionButton(L10n.tkEidRequestDataPrivacyLinkText, { _ in
          openLink(L10n.tkEidRequestDataPrivacyLinkValue)
        }),
      ],
      actions: [
        .primary(L10n.tkEidRequestDataPrivacyPrimaryButton, identifier: "primaryButton", { navigator in
          navigator.navigate(to: EIDRequestDestinations.setupSDK)
        }),
      ])
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  private func openLink(_ link: String) {
    guard let url = URL(string: link) else { return }
    openURL(url)
  }
}

#Preview {
  DataPrivacyView()
}
