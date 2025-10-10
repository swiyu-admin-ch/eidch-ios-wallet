import BITL10n
import BITTheming
import SwiftUI

// MARK: - InQueueCell

struct AgentReviewCell: View {

  // MARK: Internal

  var viewModel: AgentReviewStateViewModel

  var body: some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      content(
        title: L10n.tkEidRequestNotificationAgentReviewPrimary(viewModel.fullName),
        content: L10n.tkEidRequestNotificationAgentReviewSecondary)
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
  private func content(title: String, content: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.custom.footnoteEmphasized)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityAddTraits(.isHeader)

      Text(content)
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
    }
    .frame(maxWidth: .infinity)
  }
}
