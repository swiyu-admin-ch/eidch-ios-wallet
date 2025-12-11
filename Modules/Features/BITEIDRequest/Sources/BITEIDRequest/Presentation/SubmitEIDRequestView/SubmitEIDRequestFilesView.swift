import BITL10n
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI


struct SubmitEIDRequestView: View {

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(primaryContent: card, secondaryContent: main)
      .navigationBarBackButtonHidden(true)
      .task {
        await viewModel.submit()
      }
      .navigate(to: $viewModel.destination)
      .toolbar(.visible)
  }

  // MARK: Private

  @InjectedObject(\.submitEIDRequestFilesViewModel) private var viewModel
  @Environment(\.navigator) private var navigator
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
        .accessibilityPriorityFocus()
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
