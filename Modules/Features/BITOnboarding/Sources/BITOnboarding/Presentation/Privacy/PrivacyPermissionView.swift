import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - PrivacyPermissionView

struct PrivacyPermissionView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.privacyPermissionViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "privacyPermissionContent"
    case primaryText
    case secondaryText
    case privacyLink
    case acceptButton
    case declineButton
  }

  var body: some View {
    InformationView(
      image: Assets.verifyCross.swiftUIImage,
      backgroundImage: ThemingAssets.Gradient.gradient6.swiftUIImage,
      content: main,
      footer: footer)
  }

  // MARK: Private

  @StateObject private var viewModel: PrivacyPermissionViewModel

}

// MARK: - Components

extension PrivacyPermissionView {

  @ViewBuilder
  private func main() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(L10n.tkOnboardingAnalyticsPrimary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)

      Text(L10n.tkOnboardingAnalyticsSecondary)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)

      ButtonLinkText(L10n.tkOnboardingAnalyticsTertiaryLinkText, {
        viewModel.openPrivacyPolicy()
      })
      .font(.custom.footnote)
      .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
      .multilineTextAlignment(.leading)
      .accessibilityLabel(L10n.tkOnboardingAnalyticsTertiaryLinkText)
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  @ViewBuilder
  private func footer() -> some View {
    DefaultInformationFooterView(
      primaryButtonLabel: L10n.tkOnboardingAnalyticsButtonPrimary,
      primaryButtonAction: { Task { await viewModel.updatePrivacyPolicy(to: true) } },
      secondaryButtonLabel: L10n.tkOnboardingAnalyticsButtonSecondary,
      secondaryButtonAction: { Task { await viewModel.updatePrivacyPolicy(to: false) } })
  }

}

#Preview {
  PrivacyPermissionView(router: OnboardingRouter())
}
