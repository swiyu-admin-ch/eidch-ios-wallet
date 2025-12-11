import BITL10n
import BITTheming
import SwiftUI

struct RequestCaseNotificationView: View {

  // MARK: Lifecycle

  init(title: String, content: String, notificationType: NotificationType = .default) {
    self.title = title
    self.content = content
    self.notificationType = notificationType
  }

  // MARK: Internal

  enum NotificationType {
    case `default`
    case dismiss(action: () -> Void)
    case primary(label: String, action: () -> Void, style: CustomButtonStyle = .tertiary)
    case complete(label: String, action: () -> Void, style: CustomButtonStyle = .tertiary, dismissAction: () -> Void)
  }

  var body: some View {
    HStack(alignment: .top, spacing: .x4) {
      if !sizeCategory.isAccessibilityCategory {
        Assets.eidRequestCaseIcon.swiftUIImage
          .accessibilityHidden(true)
      }

      switch notificationType {
      case .default: mainContent()
      case .dismiss(let action): dismissCellView(action: action)
      case .primary(let label, let action, let style): primaryCellView(label: label, action: action, buttonStyle: style)
      case .complete(let label, let action, let style, let dismissAction): completeCellView(primaryActionLabel: label, primaryAction: action, dismissAction: dismissAction, buttonStyle: style)
      }
    }
    .frame(maxWidth: .infinity)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let title: String
  private let content: String
  private let notificationType: NotificationType

  @ViewBuilder
  private func mainContent() -> some View {
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

  @ViewBuilder
  private func primaryCellView(label: String, action: @escaping () -> Void, buttonStyle: CustomButtonStyle) -> some View {
    VStack(alignment: .leading) {
      mainContent()

      Button(label, action: {
        Task { action() }
      })
      .buttonStyle(buttonStyle)
      .controlSize(.regular)
      .padding(.top, .x2)
      .dynamicTypeSize(...DynamicTypeSize.accessibility2)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    }

    Spacer()
  }

  @ViewBuilder
  private func dismissCellView(action: @escaping () -> Void) -> some View {
    mainContent()

    Button(action: {
      Task { action() }
    }, label: {
      Assets.close.swiftUIImage
        .accessibilityLabel(L10n.tkEidRequestNotificationCloseButton)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    })
  }

  @ViewBuilder
  private func completeCellView(primaryActionLabel: String, primaryAction: @escaping () -> Void, dismissAction: @escaping () -> Void, buttonStyle: CustomButtonStyle) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      primaryCellView(label: primaryActionLabel, action: primaryAction, buttonStyle: buttonStyle)

      Button(action: {
        Task { dismissAction() }
      }, label: {
        Assets.close.swiftUIImage
          .accessibilityLabel(L10n.tkEidRequestNotificationCloseButton)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      })
    }
  }
}
