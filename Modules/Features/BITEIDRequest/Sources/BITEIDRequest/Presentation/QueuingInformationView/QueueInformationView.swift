import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - QueueInformationView

struct QueueInformationView: View {

  // MARK: Lifecycle

  init(onlineSessionStartDate: Date) {
    viewModel = Container.shared.queueInformationViewModel(onlineSessionStartDate)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.timer.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: { main() },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: { navigator.dismiss() })
      })
      .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case startDateText
  }

  @Environment(\.navigator) private var navigator

  private var viewModel: QueueInformationViewModel
}

// MARK: - Components

extension QueueInformationView {

  private func main() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(L10n.tkEidRequestQueuingTitle)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkEidRequestQueuingBody)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)

      VStack {
        Text(L10n.tkEidRequestQueuingBody2Ios)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.tertiaryText.rawValue)

        Text(viewModel.expectedOnlineSessionStart)
          .font(.custom.bodyBold)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.startDateText.rawValue)
      }
    }
    .frame(maxWidth: .infinity)
    .toolbar(.visible)
  }
}

#Preview {
  QueueInformationView(onlineSessionStartDate: Date())
}
