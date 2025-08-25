import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - ScanDocumentSubmitView

struct ScanDocumentSubmitView: View {

  // MARK: Lifecycle

  init(_ scanDocumentOutput: ScanDocumentOutput, router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.scanDocumentSubmitViewModel((scanDocumentOutput, router)))
  }

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(primaryContent: card, secondaryContent: main)
      .navigationBarBackButtonHidden(true)
      .task {
        await viewModel.submit()
      }
      .onAppear {
        resetAccessibilityFocus()
      }
  }

  // MARK: Private

  @AccessibilityFocusState private var errorFocusedState: Bool
  @AccessibilityFocusState private var isCurrentPageFocused: Bool

  @StateObject private var viewModel: ScanDocumentSubmitViewModel

  private func resetAccessibilityFocus() {
    DispatchQueue.main.async {
      isCurrentPageFocused = false
      isCurrentPageFocused = true
    }
  }

}

// MARK: - Components

extension ScanDocumentSubmitView {

  @ViewBuilder
  private func card() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor), content: {
      ProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage, sequence: .infiniteRandomSequence)
    })
    .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private func main() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text("Processing data...")
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .accessibilityFocused($isCurrentPageFocused)
        .accessibilityAddTraits(.isHeader)

      Text("Your MRZ data is being prepared and sent for validation.")
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .x6)
    .padding(.bottom)
  }

}
