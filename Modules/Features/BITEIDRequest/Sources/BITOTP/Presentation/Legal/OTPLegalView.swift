import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

struct OTPLegalView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.legal.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestOtpLegalTitle, identifier: "primaryText"),
        .body(L10n.tkEidRequestOtpLegalBody, identifier: "secondaryText"),
        .captionButton(L10n.tkEidRequestOtpLegalLinkText, { _ in
          openLink(L10n.tkEidRequestOtpLegalLinkValue)
        }),
      ],
      actions: [
        .primary(L10n.tkEidRequestOtpLegalPrimaryButton, identifier: "primaryButton", { navigator in
          navigator.navigate(to: OTPDestinations.email)
        }),
      ])
      .toolbar {
        CloseButtonToolbar(accessibilityIdentifier: "closeButton") {
          navigator.dismiss()
        }
      }
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
  OTPLegalView()
}
