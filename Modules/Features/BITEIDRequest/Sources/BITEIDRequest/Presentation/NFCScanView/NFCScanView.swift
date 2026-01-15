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
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)

      switch viewModel.state {
      case .sdkInitializing:
        loadingView()
          .transition(.opacity)
          .task {
            viewModel.initializeSDK()
          }
      case .ready:
        nfcScanView()
      }
    }
    .navigate(to: $viewModel.destination)
    .navigationBarBackButtonHidden(true)
    .toolbar(content: toolbarContent)
  }

  // MARK: Private

  @InjectedObject(\.nfcScanViewModel) private var viewModel: NFCScanViewModel
  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol
  @Environment(\.navigator) private var navigator

  private let imageMinWidth: CGFloat = 80
  private let imageMaxWidth: CGFloat = 250
  private let imageMinHeight: CGFloat = 80
  private let imageMaxHeight: CGFloat = 250

}

// MARK: - Loading state

extension NFCScanView {

  @ViewBuilder
  private func loadingView() -> some View {
    VStack {
      ProgressView()
      Text(L10n.tkEidRequestSdkInitializationPrimary)
    }
  }

  @ViewBuilder
  private func nfcScanView() -> some View {
    AdaptiveColumnsView(
      primaryContent: {
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
          Assets.nfc.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(minWidth: imageMinWidth, maxWidth: imageMaxWidth, minHeight: imageMinHeight, maxHeight: imageMaxHeight)
        }
        .accessibilityHidden(true)
      },
      secondaryContent: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestNfcScanPrimary,
          secondary: L10n.tkEidRequestNfcScanSecondary)
          .padding(.horizontal, .x6)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestNfcScanPrimaryButton,
          primaryButtonAction: {
            Task {
              await viewModel.startNFCScan()
            }
          })
      })
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      Button(action: {
        navigator.navigate(to: EIDRequestDestinations.nfcHelp)
      }, label: {
        Assets.questionMark.swiftUIImage
      })
      .accessibilityLabel(L10n.tkEidRequestNfcScanTertiary)

      Button(action: {
        coordinator.cleanup()
        navigator.dismiss()
      }, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }
}

#Preview {
  NFCScanView()
}
