import BITL10n
import SwiftUI

// MARK: - Request Case Dismissal with External Keyboard

extension View {
  func externalKeyboardDismissActions(_ notificationType: RequestCaseNotificationView.NotificationType) -> some View {
    modifier(RequestCaseKeyboardDismissModifier(notificationType: notificationType))
  }
}

// MARK: - RequestCaseKeyboardDismissModifier

private struct RequestCaseKeyboardDismissModifier: ViewModifier {

  // MARK: Internal

  let notificationType: RequestCaseNotificationView.NotificationType

  func body(content: Content) -> some View {
    switch notificationType {
    case .default,
         .primary:
      content

    case .complete(_, _, _, let dismissAction),
         .dismiss(let dismissAction):
      content
        .externalKeyboardShortcut(.keyboardDeleteOrBackspace, .keyboardEscape) {
          isConfirmationAlertPresented = true
        }
        .alert(
          L10n.tkEidRequestNotificationCloseAlertTitle,
          isPresented: $isConfirmationAlertPresented,
          actions: { alertActions(dismiss: dismissAction) },
          message: { Text(L10n.tkEidRequestNotificationCloseAlertMessage) })

        // Adjusts List's seperator leading's padding since UIHostingController breaks
        // SwiftUI's communication between the row's view and the List.
        .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in separatorLeadingInset })
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  @State private var isConfirmationAlertPresented = false

  private var separatorLeadingInset: CGFloat {
    guard !sizeCategory.isAccessibilityCategory else { return .x4 }
    return .x4 + Assets.eidRequestCaseIcon.image.size.width
  }

  @ViewBuilder
  private func alertActions(dismiss: @escaping () -> Void) -> some View {
    Button(role: .cancel) {
      isConfirmationAlertPresented = false
    } label: {
      Text(L10n.tkGlobalCancel)
    }

    Button(role: .destructive) {
      dismiss()
    } label: {
      Text(L10n.tkGlobalClose)
    }
  }
}
