import BITL10n
import BITTheming
import SwiftUI

struct DeclinedCell: View {

  // MARK: Internal

  var viewModel: DeclinedStateViewModel

  var body: some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        content()
        faqButton()
      }

      deleteButton()
    }
    .frame(maxWidth: .infinity)
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
  private func faqButton() -> some View {
    Button(L10n.tkEidRequestNotificationDeclinedPrimaryButton, action: viewModel.openFAQ)
      .buttonStyle(.tertiary)
      .controlSize(.regular)
      .dynamicTypeSize(...DynamicTypeSize.accessibility2)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }

  @ViewBuilder
  private func deleteButton() -> some View {
    Button(action: {
      Task {
        await viewModel.deleteRequestCase()
      }
    }, label: {
      Assets.close.swiftUIImage
        .accessibilityLabel(L10n.tkGlobalClose)
        .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
    })
  }

  @ViewBuilder
  private func content() -> some View {
    VStack(alignment: .leading) {
      Text(L10n.tkEidRequestNotificationDeclinedPrimary(viewModel.fullName))
        .font(.custom.footnoteEmphasized)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityAddTraits(.isHeader)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      Text(L10n.tkEidRequestNotificationDeclinedSecondary)
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
    }
  }
}
