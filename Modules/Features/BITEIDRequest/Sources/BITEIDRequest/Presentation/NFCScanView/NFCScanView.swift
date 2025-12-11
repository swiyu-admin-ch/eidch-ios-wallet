import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - NFCScanView

struct NFCScanView: View {

  // MARK: Internal

  var body: some View {
    VStack {
      switch viewModel.state {
      case .sdkInitializing:
        loadingView()
      case .ready:
        nfcScanView()
      case .error(let error):
        Text(error.localizedDescription)
      }
    }
    .navigate(to: $viewModel.destination)
    .navigationBarBackButtonHidden(true)
    .toolbar(content: toolbarContent)
  }

  // MARK: Private

  @InjectedObject(\.nfcScanViewModel) private var viewModel: NFCScanViewModel
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
    AdaptiveColumnsView(
      primaryContent: {
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
          InfiniteProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage)
        }
        .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
      },
      secondaryContent: {
        Text(L10n.tkEidRequestSdkInitializationPrimary)
          .font(.custom.title)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .accessibilityAddTraits(.isHeader)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, .x6)
      })
      .onFirstAppear {
        Task {
          viewModel.initializeSDK()
        }
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
        navigator.dismiss()
      }, label: {
        Assets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }
}

#Preview {
  NFCScanView()
}
