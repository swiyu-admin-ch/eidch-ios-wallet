import BITL10n
import BITTheming
import SwiftUI

struct UnknownCell: View {

  // MARK: Internal

  var viewModel: UnknownStateViewModel

  var body: some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        VStack(alignment: .leading) {
          Text(L10n.tkGetEidNotificationEidUnknownStatePrimary(viewModel.fullName))
            .font(.custom.footnoteEmphasized)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityAddTraits(.isHeader)
            .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

          Text(L10n.tkGetEidNotificationEidUnknownStateSecondary)
            .font(.custom.footnote)
            .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
            .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
        }

        Button(L10n.tkGetEidNotificationEidUnknownStateButton) {
          Task {
            await viewModel.primaryAction()
          }
        }
        .buttonStyle(.bezeled)
        .controlSize(.regular)
        .padding(.top, .x2)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      }

      Spacer()
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
}
