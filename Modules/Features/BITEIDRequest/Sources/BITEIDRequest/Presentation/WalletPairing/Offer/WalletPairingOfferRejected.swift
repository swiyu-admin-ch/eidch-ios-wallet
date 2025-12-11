import BITL10n
import BITTheming
import Foundation
import NavigatorUI
import SwiftUI

struct WalletPairingOfferRejected: View {

  // MARK: Internal

  var onRetry: (Void) -> Void

  var body: some View
  {
    InformationView(
      image: Assets.walletPairing.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor)
    {
      DefaultInformationContentView(
        primary: L10n.tkEidRequestWalletPairingOfferRejectedPrimary,
        secondary: L10n.tkEidRequestWalletPairingOfferRejectedSecondary,
        tertiary: L10n.tkEidRequestWalletPairingOfferRejectedTertiary,
        tertiaryAction: { openLink(L10n.tkEidRequestWalletPairingOfferRejectedTertiaryLink) })
    } footer: {
      DefaultInformationFooterView(
        primaryButtonLabel: L10n.tkEidRequestWalletPairingOfferRejectedButtonPrimary,
        primaryButtonAction: {
          onRetry(Void())
          navigator.returnToCheckpoint(EIDRequestCheckpoints.walletPairingOffer)
        })
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @Environment(\.openURL) private var openURL

  private func openLink(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    openURL(url)
  }

}
