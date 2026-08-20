import BITL10n
import SwiftUI

// MARK: - CloseButtonToolbar

public struct CloseButtonToolbar: ToolbarContent {

  // MARK: Lifecycle

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  // MARK: Public

  public var body: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      closeButton
        .accessibilityIdentifier(accessibilityIdentifier)
        .if(hasFocusPriority) { $0.accessibilityPriorityFocus(delay: .seconds(0)) }
    }
  }

  // MARK: Private

  @Environment(\.closeButtonAccessibilityIdentifier) private var accessibilityIdentifier
  @Environment(\.closeButtonAccessibilityPriorityFocus) private var hasFocusPriority

  private let action: () -> Void

  @ViewBuilder
  private var closeButton: some View {
    if #available(iOS 26.0, *) {
      Button(role: .close, action: action)
    } else {
      Button(action: action, label: {
        Image(systemName: "xmark")
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }
}

extension EnvironmentValues {
  @Entry fileprivate var closeButtonAccessibilityIdentifier = "closeButton"
  @Entry fileprivate var closeButtonAccessibilityPriorityFocus = false
}

extension View {
  public func toolbarCloseButtonAccessibilityIdentifier(_ identifier: String) -> some View {
    environment(\.closeButtonAccessibilityIdentifier, identifier)
  }

  public func toolbarCloseButtonAccessibilityPriorityFocus(_ hasFocusPriority: Bool = true) -> some View {
    environment(\.closeButtonAccessibilityPriorityFocus, hasFocusPriority)
  }
}
