import BITL10n
import BITTheming
import SwiftUI

struct ExpiredCell: View {

  // MARK: Internal

  var viewModel: ExpiredStateViewModel

  var body: some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        Text(L10n.tkEidRequestNotificationEidExpiredPrimary(viewModel.fullName))
          .font(.custom.footnoteEmphasized)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityAddTraits(.isHeader)
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

        Text(L10n.tkEidRequestNotificationEidExpiredSecondary)
          .font(.custom.footnote)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
          .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      }

      Button(action: {
        Task {
          await viewModel.primaryAction()
        }
      }, label: {
        Assets.close.swiftUIImage
          .accessibilityLabel(L10n.tkEidRequestNotificationCloseButton)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      })
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
}
