import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - BiometricsView

struct BiometricsView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.biometricsViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "biometricsViewContent"
    case primaryText
    case secondaryText
  }

  var body: some View {
    InformationView(
      image: viewModel.image,
      backgroundImage: ThemingAssets.Gradient.gradient4.swiftUIImage,
      content: main,
      footer: footer)
      .popup(isPresented: $viewModel.isErrorPresented) {
        if let error = viewModel.error {
          Notification(
            systemImageName: "exclamationmark.triangle",
            imageColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
            content: error.localizedDescription,
            contentColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
            closeAction: {
              viewModel.hideError()
            })
            .padding(.horizontal, .x4)
            .environment(\.colorScheme, .light)
            .accessibilityElement(children: .combine)
            .accessibilitySortPriority(10)
            .accessibilityHidden(!viewModel.isErrorPresented)
            .accessibilityFocused($errorFocusedState)
            .onAppear {
              errorFocusedState = viewModel.isErrorPresented
            }
        }
      } customize: {
        $0.type(.floater())
          .appearFrom(.bottomSlide)
          .closeOnTap(true)
          .autohideIn(UIAccessibility.isVoiceOverRunning ? nil : viewModel.autoHideErrorDelay)
          .animation(Constants.errorAnimation)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private enum Constants {
    static var errorAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 30)
  }

  @AccessibilityFocusState private var errorFocusedState: Bool

  @StateObject private var viewModel: BiometricsViewModel
}

// MARK: - Components

extension BiometricsView {

  @ViewBuilder
  private func main() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(viewModel.primaryText)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(viewModel.primaryText)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)

      Text(viewModel.secondaryText)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .accessibilityLabel(viewModel.secondaryText)
        .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)

      Text(viewModel.tertiaryText)
        .font(.custom.footnote)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .accessibilityLabel(viewModel.tertiaryText)
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom)
  }

  @ViewBuilder
  private func footer() -> some View {
    DefaultInformationFooterView(
      primaryButtonLabel: viewModel.hasBiometricAuth ? L10n.tkOnboardingBiometricsPermissionButtonPrimary : L10n.tkOnboardingBiometricsPermissionDisabledButtonPrimary,
      primaryButtonAction: { Task { viewModel.hasBiometricAuth ? await viewModel.registerBiometrics() : viewModel.openSettings() } },
      secondaryButtonLabel: L10n.tkGlobalNo,
      secondaryButtonAction: viewModel.skip)
  }

}

#Preview {
  BiometricsView(router: OnboardingRouter())
}
