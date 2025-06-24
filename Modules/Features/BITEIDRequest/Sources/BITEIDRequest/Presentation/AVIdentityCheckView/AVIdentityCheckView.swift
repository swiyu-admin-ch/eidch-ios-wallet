import BITL10n
import BITTheming
import Factory
import SwiftUI

struct AVIdentityCheckView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.avIdentityCheckViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.idCheck.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: { content() },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestAutoVerificationIdentityCheckButton,
          primaryButtonAction: viewModel.primaryAction)
      })
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case tertiaryTipText
  }

  private var viewModel: AVIdentityCheckViewModel

  @ViewBuilder
  private func content() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(L10n.tkEidRequestAutoVerificationIdentityCheckPrimary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkEidRequestAutoVerificationIdentityCheckSecondary)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)

      VStack(spacing: 0) {
        Text(L10n.tkEidRequestAutoVerificationIdentityCheckTertiaryTip)
          .font(.custom.bodyBold)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.tertiaryTipText.rawValue)

        Text(L10n.tkEidRequestAutoVerificationIdentityCheckTertiary)
          .font(.custom.footnote)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.tertiaryText.rawValue)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .x6)
    .padding(.bottom)
  }
}

#Preview {
  AVIdentityCheckView(router: EIDRequestRouter())
}
