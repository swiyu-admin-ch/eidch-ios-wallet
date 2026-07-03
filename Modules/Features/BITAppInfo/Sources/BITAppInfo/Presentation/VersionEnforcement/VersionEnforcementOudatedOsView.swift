import BITL10n
import SwiftUI

struct VersionEnforcementOudatedOsView: View {

  // MARK: Internal

  var body: some View {
    VersionEnforcementContentView(
      title: L10n.tkVersionEnforcementSystemUpdateTitle,
      content: L10n.tkVersionEnforcementSystemUpdateContent)
    {
      openSettingsButton()
    }
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  private func openSettingsButton() -> some View {
    Button {
      guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
        return
      }
      openURL(settingsURL)
    } label: {
      Text(L10n.tkVersionEnforcementSystemUpdateButton)
        .frame(maxWidth: .infinity)
    }
    .controlSize(.large)
    .buttonStyle(.primary)
    .accessibilityLabel(L10n.tkVersionEnforcementSystemUpdateButton)
    .accessibilityHint(L10n.tkGlobalExternalLinkHint)
  }
}
