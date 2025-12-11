import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - ValidateAttestationsView

struct ValidateAttestationsView: View {

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(
      primaryContent: leftContent,
      secondaryContent: rightContent)
      .toolbar(.visible)
      .navigationBarBackButtonHidden()
      .navigate(to: $viewModel.destination)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .onFirstAppear {
        Task {
          await viewModel.fetchAttestations()
        }
      }
  }

  // MARK: Private

  @InjectedObject(\.validateAttestationsViewModel) private var viewModel
}

// MARK: - Components

extension ValidateAttestationsView {

  @ViewBuilder
  private func leftContent() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
      InfiniteProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage)
    }
    .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
  }

  @ViewBuilder
  private func rightContent() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(L10n.tkEidRequestAttestationPrimary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .accessibilityPriorityFocus()
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)

      Text(L10n.tkEidRequestAttestationSecondary)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, .x6)
  }

}

#Preview {
  ValidateAttestationsView()
}
