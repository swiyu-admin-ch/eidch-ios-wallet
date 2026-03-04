import BITL10n
import BITTheming
import Factory
import SwiftUI

struct ScanDocumentSubmitView: View {

  // MARK: Lifecycle

  init(_ scanDocumentOutput: ScanDocumentOutput) {
    _viewModel = StateObject(wrappedValue: Container.shared.scanDocumentSubmitViewModel(scanDocumentOutput))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      contents: [
        .heroCard {
          Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
            ProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage, sequence: .infiniteRandomSequence)
          }
          .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
          .accessibilityHidden(true)
        },
        .title(L10n.tkEidRequestScanDocumentInitializationPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestScanDocumentInitializationSecondary, identifier: "secondaryText"),
      ])
      .task {
        await viewModel.submit()
      }
      .navigationBarBackButtonHidden()
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .navigate(to: $viewModel.destination)
      .toolbar(.visible)
  }

  // MARK: Private

  @StateObject private var viewModel: ScanDocumentSubmitViewModel
}
