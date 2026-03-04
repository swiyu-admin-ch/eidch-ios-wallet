import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - WalletPairingOfferView

struct WalletPairingOfferView: View {

  // MARK: Lifecycle

  init(_ didPairWalletHandler: @escaping (Void) -> Void) {
    _viewModel = StateObject(wrappedValue: Container.shared.walletPairingOfferViewModel(didPairWalletHandler))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      contents: [
        .heroCard { card() },
        .title(L10n.tkWalletPairingDevicePairingQRCodePrimary, identifier: "primaryText"),
        .body(L10n.tkWalletPairingDevicePairingQRCodeSecondary, identifier: "secondaryText"),
      ],
      actions: actions)
      .background(ThemingAssets.Background.primary.swiftUIColor)
      .task {
        await viewModel.fetchPairingQRCode()
      }
      .toolbar(.visible)
      .toolbar(content: {
        CloseButtonToolbar(accessibilityIdentifier: "closeButton") {
          navigator.dismiss()
        }
      })
      .toolbarBackground(ThemingAssets.Background.primary.swiftUIColor, for: .navigationBar)
      .navigate(to: $viewModel.destination)
      .navigationCheckpoint(EIDRequestCheckpoints.walletPairingOffer)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @StateObject private var viewModel: WalletPairingOfferViewModel

  private let qrCodeSize = 250.0
}

extension WalletPairingOfferView {

  @ViewBuilder
  private var actions: [InformationView2.ActionType] {
    var actions = [InformationView2.ActionType]()

    if viewModel.walletPairingPollingManager.isPolling {
      actions.append(.anyView { pollingStatusView() })
    }

    actions.append(.secondary(L10n.tkGlobalClose, { _ in
      viewModel.close()
    }))

    return actions
  }

  private func card() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
      switch viewModel.state {
      case .loading: loadingView()
      case .error: errorView()
      case .result: qrCodeView()
      }
    }
    .disableAXResizing()
  }

  private func errorView() -> some View {
    VStack(spacing: .x6) {
      VStack {
        Assets.emergency.swiftUIImage
          .accessibilityHidden(true)
        Text(L10n.tkWalletPairingDevicePairingQRCodeFetchErrorBody)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .font(.custom.body)
          .multilineTextAlignment(.center)
      }

      Button(L10n.tkWalletPairingDevicePairingQRCodeFetchErrorButton) {
        Task {
          await viewModel.fetchPairingQRCode()
        }
      }
      .buttonStyle(.bezeled)
    }
    .frame(maxWidth: qrCodeSize)
  }

  private func loadingView() -> some View {
    ProgressView()
      .controlSize(.large)
  }

  @ViewBuilder
  private func qrCodeView() -> some View {
    if case .result(let imageData) = viewModel.state {
      Image(data: imageData)?
        .resizable()
        .frame(width: qrCodeSize, height: qrCodeSize)
        .accessibilityLabel(L10n.tkWalletPairingDevicePairingQRCodeQrCodeAlt)
    }
  }

  private func pollingStatusView() -> some View {
    HStack {
      ProgressView()

      Text(L10n.tkWalletPairingDevicePairingQRCodeFetchDeviceBody)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  WalletPairingOfferView({ _ in })
}
