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
          title: L10n.tkEidRequestNotificationEidProgressPrimary(viewModel.fullName),
          content: L10n.tkEidRequestNotificationEidProgressSecondary(viewModel.formattedDate))
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
          title: L10n.tkEidRequestNotificationLegalRepresentantPendingConsentInQueuePrimary,
          content: L10n.tkEidRequestNotificationLegalRepresentantPendingConsentInQueueSecondary)

        Button(L10n.tkEidRequestNotificationLegalRepresentantPendingConsentInQueueButton, action: viewModel.primaryAction)
          .buttonStyle(.tertiary)
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
