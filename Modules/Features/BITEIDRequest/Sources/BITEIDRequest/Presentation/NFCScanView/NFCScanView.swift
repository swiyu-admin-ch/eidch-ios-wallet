import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - NFCScanView

struct NFCScanView: View {

  // MARK: Internal

  var body: some View {
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)

      switch viewModel.state {
      case .sdkInitializing:
        LoadingView(
          primary: L10n.tkLoaderInitializationPrimary,
          secondary: L10n.tkLoaderInitializationSecondary,
          action: LoadingView.Action(
            action: close,
            buttonText: L10n.tkGlobalCancel))
          .transition(.opacity)
          .task {
            viewModel.initializeSDK()
          }
      case .ready:
        nfcScanView()
      }
    }
    .navigate(to: $viewModel.destination)
    .navigationBarBackButtonHidden()
    .toolbar(content: toolbarContent)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @InjectedObject(\.nfcScanViewModel) private var viewModel: NFCScanViewModel
  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  private let imageMinWidth: CGFloat = 80
  private let imageMaxWidth: CGFloat = 250
  private let imageMinHeight: CGFloat = 80
  private let imageMaxHeight: CGFloat = 250
}

// MARK: - Loading state

extension NFCScanView {
  private func nfcScanView() -> some View {
    InformationView2(
      contents: [
        .heroCard {
          Assets.nfc.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(minWidth: imageMinWidth, maxWidth: imageMaxWidth, minHeight: imageMinHeight, maxHeight: imageMaxHeight)
        },
        .title(L10n.tkEidRequestNfcScanPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestNfcScanSecondary, identifier: "secondaryText"),
      ],
      actions: [
        .primary(L10n.tkEidRequestNfcScanPrimaryButton, identifier: "primaryButton", { _ in
          Task {
            await viewModel.startNFCScan()
          }
        }),
      ])
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      Button(action: close, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }

  private func close() {
    coordinator.cleanup()
    navigator.dismiss()
  }
}

#Preview {
  NFCScanView()
}
