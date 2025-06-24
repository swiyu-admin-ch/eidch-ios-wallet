import BITL10n
import BITTheming
import SwiftUI

// MARK: - InQueueCell

struct InQueueCell: View {

  // MARK: Internal

  var viewModel: InQueueStateViewModel

  var body: some View {
    if viewModel.isLegalRepresentantConsentVerified {
      inQueueViewVerifiedConsent(viewModel)
    } else {
      inQueueViewNotVerifiedConsent(viewModel)
    }
  }

  // MARK: Private

  private enum AccessibilityPriority: Double {
    case x1 = 100
    case x2 = 80
    case x3 = 50
  }

  @Environment(\.sizeCategory) private var sizeCategory

  @ViewBuilder
  private func image() -> some View {
    if !sizeCategory.isAccessibilityCategory {
      Assets.eidRequestCaseIcon.swiftUIImage
        .accessibilityHidden(true)
    }
  }

  @ViewBuilder
  private func inQueueViewVerifiedConsent(_ viewModel: InQueueStateViewModel) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        content(
          title: L10n.tkGetEidNotificationEidProgressPrimary(viewModel.fullName),
          content: L10n.tkGetEidNotificationEidProgressSecondary(viewModel.formattedDate))
      }

      Spacer()
    }
  }

  @ViewBuilder
  private func inQueueViewNotVerifiedConsent(_ viewModel: InQueueStateViewModel) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        content(
          title: L10n.tkGetEidNotificationLegalRepresentantPendingConsentInQueuePrimary,
          content: L10n.tkGetEidNotificationLegalRepresentantPendingConsentInQueueSecondary)

        Button(L10n.tkGetEidNotificationLegalRepresentantPendingConsentInQueueButton, action: viewModel.primaryAction)
          .buttonStyle(.filledSecondary)
          .controlSize(.regular)
          .padding(.top, .x2)
          .dynamicTypeSize(...DynamicTypeSize.accessibility2)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      }

      Spacer()
    }
  }
}

extension InQueueCell {

  @ViewBuilder
  private func content(title: String, content: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.custom.footnoteEmphasized)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityAddTraits(.isHeader)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      Text(content)
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
    }
  }
}
