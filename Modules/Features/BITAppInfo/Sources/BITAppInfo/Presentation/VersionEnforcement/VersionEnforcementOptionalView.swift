import BITL10n
import BITTheming
import SwiftUI

struct VersionEnforcementOptionalView: View {

  // MARK: Internal

  let message: VersionEnforcement.Message?
  let onDismiss: () -> Void

  var body: some View {
    VersionEnforcementContentView(
      title: message?.title ?? L10n.tkVersionEnforcementOptionalTitle,
      content: message?.body ?? L10n.tkVersionEnforcementOptionalBody)
    {
      updateButton()
      updateLaterButton()
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

  private func updateLaterButton() -> some View {
    Button {
      onDismiss()
    } label: {
      Text(L10n.tkVersionEnforcementLaterButton)
        .frame(maxWidth: .infinity)
    }
    .padding(.vertical, .x2)
    .padding(.horizontal, .x4)
    .buttonStyle(.borderless)
    .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
    .accessibilityLabel(L10n.tkVersionEnforcementLaterButton)
  }
}
