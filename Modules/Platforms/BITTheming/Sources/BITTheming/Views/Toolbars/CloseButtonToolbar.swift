import BITL10n
import SwiftUI

public struct CloseButtonToolbar: ToolbarContent {
  public init(accessibilityIdentifier: String = "closeButton", action: @escaping () -> Void) {
    self.accessibilityIdentifier = accessibilityIdentifier
    self.action = action
  }

  public var body: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: action, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
      .accessibilityIdentifier(accessibilityIdentifier)
    }
  }

  private let accessibilityIdentifier: String
  private let action: () -> Void
}
