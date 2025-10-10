import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI


struct SubmitEIDRequestView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.submitEIDRequestFilesViewModel(router))
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

  @StateObject private var viewModel: SubmitEIDRequestFilesViewModel

  private func resetAccessibilityFocus() {
    DispatchQueue.main.async {
      isCurrentPageFocused = false
      isCurrentPageFocused = true
    }
  }

}

// MARK: - Components

extension SubmitEIDRequestView {

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
      Text(L10n.tkEidRequestSubmitDocumentsPrimary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .accessibilityFocused($isCurrentPageFocused)
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkEidRequestSubmitDocumentsSecondary)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .x6)
    .padding(.bottom)
  }

}
