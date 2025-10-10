import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - AVDevicePairingQRCodeView

struct AVDevicePairingQRCodeView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, delegate: DevicePairingDelegate? = nil) {
    _viewModel = StateObject(wrappedValue: Container.shared.avDevicePairingQRCodeViewModel((router, delegate)))
  }

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(primaryContent: card) {
      DefaultInformationContentView(
        primary: L10n.tkWalletPairingDevicePairingQRCodePrimary,
        secondary: L10n.tkWalletPairingDevicePairingQRCodeSecondary)
        .padding(.horizontal, .x6)
    } footer: {
      viewFooter()
    }
    .background(ThemingAssets.Background.primary.swiftUIColor)
    .task {
      await viewModel.fetchPairingQRCode()
    }
    .toolbar(content: toolbarContent)
    .toolbarBackground(ThemingAssets.Background.primary.swiftUIColor, for: .navigationBar)
  }

  // MARK: Private

  @StateObject private var viewModel: AVDevicePairingQRCodeViewModel

  private let qrCodeSize = 250.0
}

extension AVDevicePairingQRCodeView {

  @ViewBuilder
  private func card() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
      switch viewModel.state {
      case .loading: loadingView()
      case .error: errorView()
      case .result: qrCodeView()
      }
    }
  }

  @ViewBuilder
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

  @ViewBuilder
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

  @ViewBuilder
  private func viewFooter() -> some View {
    ButtonSheet {
      VStack {
        if viewModel.walletPairingPollingManager.isPolling {
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

        Button(action: viewModel.close) {
          Text(L10n.tkGlobalClose)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.secondary)
        .controlSize(.large)
      }
    }
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: viewModel.close, label: {
        Assets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }

}

#Preview {
  AVDevicePairingQRCodeView(router: EIDRequestRouter())
}
