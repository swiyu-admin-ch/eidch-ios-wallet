import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct AVWelcomeView: View {

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.hand.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: { content() },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestAutoVerificationWelcomeButton,
          primaryButtonAction: viewModel.primaryAction)
      })
      .navigate(to: $viewModel.destination)
      .defaultEidRequestToolbar()
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case tertiaryTipText
  }

  @InjectedObject(\.avWelcomeViewModel) private var viewModel

  @ViewBuilder
  private func content() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(L10n.tkEidRequestAutoVerificationWelcomePrimary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkEidRequestAutoVerificationWelcomeSecondary)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)

      VStack(spacing: 0) {
        Text(L10n.tkEidRequestAutoVerificationWelcomeTertiaryTip)
          .font(.custom.bodyBold)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.tertiaryTipText.rawValue)

        Text(L10n.tkEidRequestAutoVerificationWelcomeTertiary)
          .font(.custom.footnote)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.tertiaryText.rawValue)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom)
  }
}

#Preview {
  AVWelcomeView()
}
