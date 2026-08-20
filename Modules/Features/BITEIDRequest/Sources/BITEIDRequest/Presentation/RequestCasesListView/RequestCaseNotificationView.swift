import BITL10n
import BITTheming
import SwiftUI

// MARK: - RequestCaseNotificationView

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
    .padding(.vertical, .x3)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title). \(content)")
    .accessibilityNotificationActions(notificationType)
    .externalKeyboardDismissActions(notificationType)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let title: String
  private let content: String
  private let notificationType: NotificationType

  private func mainContent() -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.custom.footnoteEmphasized)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)

      Text(content)
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func primaryCellView(label: String, action: @escaping () -> Void, buttonStyle: CustomButtonStyle) -> some View {
    VStack(alignment: .leading) {
      mainContent()

      Button(label, action: {
        Task { action() }
      })
      .buttonStyle(buttonStyle)
      .controlSize(.regular)
      .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
  }

  @ViewBuilder
  private func dismissCellView(action: @escaping () -> Void) -> some View {
    mainContent()

    Button(action: {
      Task { action() }
    }, label: {
      Image(systemName: "xmark")
    })
    .buttonStyle(.borderless)
    .accessibilityHidden(true)
  }

  private func completeCellView(primaryActionLabel: String, primaryAction: @escaping () -> Void, dismissAction: @escaping () -> Void, buttonStyle: CustomButtonStyle) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      primaryCellView(label: primaryActionLabel, action: primaryAction, buttonStyle: buttonStyle)

      Button(action: {
        Task { dismissAction() }
      }, label: {
        Image(systemName: "xmark")
      })
      .accessibilityHidden(true)
    }
  }
}


extension View {
  fileprivate func accessibilityNotificationActions(_ notificationType: RequestCaseNotificationView.NotificationType) -> some View {
    modifier(AccessibilityActionsModifier(notificationType: notificationType))
  }
}

// MARK: - AccessibilityActionsModifier

fileprivate struct AccessibilityActionsModifier: ViewModifier {
  let notificationType: RequestCaseNotificationView.NotificationType

  func body(content: Content) -> some View {
    switch notificationType {
    case .default:
      content

    case .dismiss(let action):
      content
        .accessibilityAction(named: L10n.tkEidRequestNotificationCloseButton, action)

    case .primary(let label, let action, _):
      content
        .accessibilityAction(named: label, action)

    case .complete(let label, let action, _, let dismissAction):
      content
        .accessibilityActions {
          Button(label, action: action)
          Button(L10n.tkEidRequestNotificationCloseButton, action: dismissAction)
        }
    }
  }
}
