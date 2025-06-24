import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - AttestationView

struct AttestationView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.attestationViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(
      primaryContent: leftContent,
      secondaryContent: rightContent)
      .navigationBarBackButtonHidden()
      .onFirstAppear {
        Task {
          await viewModel.fetchAttestations()
        }
      }
      .onAppear {
        resetAccessibilityFocus()
      }
  }

  // MARK: Private

  @AccessibilityFocusState private var isCurrentPageFocused: Bool
  @StateObject private var viewModel: AttestationViewModel

  private func resetAccessibilityFocus() {
    DispatchQueue.main.async {
      isCurrentPageFocused = false
      isCurrentPageFocused = true
    }
  }
}

// MARK: - Components

extension AttestationView {

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
        .accessibilityFocused($isCurrentPageFocused)
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
  AttestationView(router: EIDRequestRouter())
}
