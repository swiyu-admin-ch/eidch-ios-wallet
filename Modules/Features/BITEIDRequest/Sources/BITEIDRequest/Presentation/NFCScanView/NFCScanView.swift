import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NFCScanView

struct NFCScanView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.nfcScanViewModel(router)
  }

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
    .navigationBarBackButtonHidden(true)
    .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private var viewModel: NFCScanViewModel

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
        viewModel.initializeSDK()
      }
  }

  @ViewBuilder
  private func nfcScanView() -> some View {
    InformationView(
      image: Assets.nfc.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestNfcScanPrimary,
          secondary: L10n.tkEidRequestNfcScanSecondary,
          tertiary: L10n.tkEidRequestNfcScanTertiary,
          tertiaryAction: viewModel.openHelp)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestNfcScanPrimaryButton,
          primaryButtonAction: viewModel.startNFCScan)
      })
  }
}

#Preview {
  NFCScanView(router: EIDRequestRouter())
}
