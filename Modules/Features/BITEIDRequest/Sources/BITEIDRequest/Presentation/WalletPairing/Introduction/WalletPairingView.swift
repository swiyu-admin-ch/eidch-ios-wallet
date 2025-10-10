import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - WalletPairingView

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
          primary: L10n.tkEidRequestWalletPairing1Title,
          secondary: L10n.tkEidRequestWalletPairing1Body,
          tertiary: L10n.tkEidRequestWalletPairing1SmallBody)
      },
      footer: footer)
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
      .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  private var viewModel: WalletPairingViewModel
}

extension WalletPairingView {

  @ViewBuilder
  private func footer() -> some View {
    ButtonSheet {
      VStack(spacing: .x4) {
        AsyncButton(
          action: { await viewModel.primaryAction() },
          actionOptions: [.showProgressView],
          label: {
            Text(L10n.tkEidRequestWalletPairing1PrimaryButton)
              .multilineTextAlignment(.center)
              .lineLimit(1)
              .frame(maxWidth: .infinity)
          })
          .buttonStyle(.primary)
          .controlSize(.large)

        AsyncButton(
          action: { await viewModel.secondaryAction() },
          actionOptions: [.showProgressView],
          label: {
            Text(L10n.tkEidRequestWalletPairing1SecondaryButton)
              .multilineTextAlignment(.center)
              .lineLimit(1)
              .frame(maxWidth: .infinity)
          })
          .buttonStyle(.secondary)
          .controlSize(.large)
      }
    }
  }
}

#Preview {
  WalletPairingView(router: EIDRequestRouter())
}
