import BITL10n
import SwiftUI

public struct CloseButtonToolbar: ToolbarContent {
  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: action, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }

  private var action: () -> Void = {}
}
