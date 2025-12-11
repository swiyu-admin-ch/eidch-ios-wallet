import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - SetupView

extension AnimationSequence {
  static let setupSequence = AnimationSequence(steps: [
    AnimationStep(size: CGSize(width: 250, height: 4), offsetX: -20, duration: 1),
    AnimationStep(size: CGSize(width: 235, height: 28), offsetX: 75, duration: 1),
    AnimationStep(size: CGSize(width: 235, height: 28), offsetX: -50, duration: 1),
    AnimationStep(size: CGSize(width: 235, height: 28), offsetX: 120, duration: 1),
  ])
}

// MARK: - SetupView

struct SetupView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.setupViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(primaryContent: card, secondaryContent: main)
      .navigationBarBackButtonHidden(true)
      .onFirstAppear {
        Task {
          await viewModel.run()
        }
      }
  }

  // MARK: Private

  @StateObject private var viewModel: SetupViewModel
}

// MARK: - Components

extension SetupView {

  @ViewBuilder
  private func card() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor), content: {
      ProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage, sequence: .setupSequence)
    })
    .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private func main() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(L10n.tkOnboardingSetupPrimary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .accessibilityPriorityFocus()
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkOnboardingSetupSecondary)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .x6)
    .padding(.bottom)
  }

}

#Preview {
  SetupView(router: OnboardingRouter())
}
