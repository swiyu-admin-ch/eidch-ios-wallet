import BITL10n
import BITTheming
import Foundation
import SwiftUI

struct WalletPairingOfferRejected: View {

  // MARK: Internal

  var onRetry: (Void) -> Void

  var body: some View
  {
    InformationView2(
      image: Assets.walletPairing.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestWalletPairingOfferRejectedPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestWalletPairingOfferRejectedSecondary, identifier: "secondaryText"),
        .captionButton(L10n.tkEidRequestWalletPairingOfferRejectedTertiary, { _ in
          openLink(L10n.tkEidRequestWalletPairingOfferRejectedTertiaryLink)
        }),
      ],
      actions: [
        .primary(L10n.tkEidRequestWalletPairingOfferRejectedButtonPrimary, identifier: "primaryButton", { navigator in
          onRetry(Void())
          navigator.returnToCheckpoint(EIDRequestCheckpoints.walletPairingOffer)
        }),
      ])
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  private func openLink(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    openURL(url)
  }

}
