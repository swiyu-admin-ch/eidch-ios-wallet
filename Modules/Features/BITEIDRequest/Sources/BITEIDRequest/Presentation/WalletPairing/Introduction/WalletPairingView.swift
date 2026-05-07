import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - WalletPairingView

struct WalletPairingView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.walletPairing.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestWalletPairing1Title, identifier: "primaryText"),
        .body(L10n.tkEidRequestWalletPairing1Body, identifier: "secondaryText"),
        .caption(L10n.tkEidRequestWalletPairing1SmallBody, identifier: "tertiaryText"),
      ],
      actions: [
        .primaryAsync(
          L10n.tkEidRequestWalletPairing1PrimaryButton, actionOptions: [.showProgressView])
        { _ in
          await viewModel.primaryAction()
        },
        .secondaryAsync(L10n.tkEidRequestWalletPairing1SecondaryButton, actionOptions: [.showProgressView]) { _ in
          await viewModel.secondaryAction()
        },
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @InjectedObservable(\.walletPairingViewModel) private var viewModel: WalletPairingViewModel
}

#Preview {
  WalletPairingView()
}
