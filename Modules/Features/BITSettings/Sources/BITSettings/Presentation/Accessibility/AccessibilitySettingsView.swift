import BITL10n
import SwiftUI

// MARK: - AccessibilitySettingsView

struct AccessibilitySettingsView: View {

  // MARK: Internal

  var body: some View {
    SettingsPage(title: L10n.tkSettingsGeneralAccessibility) {
      SettingsSection {
        SettingsItem(
          image: Assets.terms.swiftUIImage,
          title: L10n.tkSettingsAccessibilityDeclarationLinkText,
          type: .link(L10n.tkSettingsAccessibilityDeclarationLinkValue))

        SettingsItem(
          image: Assets.feedback.swiftUIImage,
          title: L10n.tkSettingsAccessibilityReportIssueLinkText,
          type: .link(L10n.tkSettingsAccessibilityReportIssueLinkValue),
          hasDivider: false)
      }
    }
  }
}

#if DEBUG
#Preview {
  AccessibilitySettingsView()
}
#endif
