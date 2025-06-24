import BITL10n
import BITTheming
import Factory
import SwiftUI

struct WalletPairingView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.walletPairingViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.walletPairing.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkGetEidWalletPairing1Title,
          secondary: L10n.tkGetEidWalletPairing1Body,
          tertiary: L10n.tkGetEidWalletPairing1SmallBody)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGetEidWalletPairing1PrimaryButton,
          primaryButtonAction: viewModel.primaryAction,
          secondaryButtonLabel: L10n.tkGetEidWalletPairing1SecondaryButton,
          secondaryButtonDisabled: true)
      })
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private var viewModel: WalletPairingViewModel
}

#Preview {
  WalletPairingView(router: EIDRequestRouter())
}
