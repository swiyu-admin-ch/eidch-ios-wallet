import BITL10n
import SwiftUI

struct VersionEnforcementForcedView: View {

  // MARK: Internal

  let message: VersionEnforcement.Message?

  var body: some View {
    VersionEnforcementContentView(
      title: message?.title ?? L10n.tkVersionEnforcementForcedTitle,
      content: message?.body ?? L10n.tkVersionEnforcementForcedBody)
    {
      updateButton()
    }
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  private func updateButton() -> some View {
    Button {
      guard let appStoreUrl = URL(string: L10n.tkGlobalStoreLink) else {
        return
      }
      openURL(appStoreUrl)
    } label: {
      Text(L10n.tkVersionEnforcementButton)
        .frame(maxWidth: .infinity)
    }
    .controlSize(.large)
    .buttonStyle(.primary)
    .accessibilityLabel(L10n.tkVersionEnforcementButton)
    .accessibilityHint(L10n.tkGlobalExternalLinkHint)
  }
}
