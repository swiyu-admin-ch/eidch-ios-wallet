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
        .captionButton(L10n.tkEidRequestOtpLegalTermsLinkText, { _ in
          openLink(L10n.tkEidRequestOtpLegalTermsLinkValue)
        }),
        .captionButton(L10n.tkEidRequestOtpLegalPrivacyLinkText, { _ in
          openLink(L10n.tkEidRequestOtpLegalPrivacyLinkValue)
        }),
      ],
      actions: [
        .primary(L10n.tkEidRequestOtpLegalPrimaryButton, identifier: "primaryButton", { navigator in
          navigator.navigate(to: OTPDestinations.email)
        }),
        .secondary(L10n.tkEidRequestOtpLegalSecondaryButton, { navigator in
          navigator.dismiss()
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
