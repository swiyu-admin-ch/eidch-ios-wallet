import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

struct ScanDocumentSubmitView: View {

  // MARK: Lifecycle

  init(_ scanDocumentOutput: ScanDocumentOutput) {
    _viewModel = StateObject(wrappedValue: Container.shared.scanDocumentSubmitViewModel(scanDocumentOutput))
  }

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(
      primaryContent: {
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor), content: {
          ProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage, sequence: .infiniteRandomSequence)
        })
        .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
        .accessibilityHidden(true)
      },
      secondaryContent: {
        DefaultInformationContentView(
          primary: "Processing data...",
          secondary: "Your MRZ data is being prepared and sent for validation.")
          .padding(.horizontal, .x6)
          .accessibilityPriorityFocus()
      })
      .task {
        await viewModel.submit()
      }
      .navigationBarBackButtonHidden(true)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .navigate(to: $viewModel.destination)
      .toolbar(.visible)
  }

  // MARK: Private

  @StateObject private var viewModel: ScanDocumentSubmitViewModel
}
