import BITL10n
import SwiftUI

struct VersionEnforcementBlacklistedDeviceView: View {

  // MARK: Internal

  var body: some View {
    VersionEnforcementContentView(
      title: L10n.tkVersionEnforcementBlacklistedTitle,
      content: L10n.tkVersionEnforcementBlacklistedContent)
    {
      supportButton()
    }
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  private func supportButton() -> some View {
    Button {
      guard let supportURL = URL(string: L10n.tkErrorGenericHelpLinkValue) else {
        return
      }
      openURL(supportURL)
    } label: {
      Text(L10n.tkVersionEnforcementBlacklistedButton)
        .frame(maxWidth: .infinity)
    }
    .controlSize(.large)
    .buttonStyle(.primary)
    .accessibilityLabel(L10n.tkVersionEnforcementBlacklistedButton)
    .accessibilityHint(L10n.tkGlobalExternalLinkHint)
  }
}
