import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - HomeMenu

struct HomeMenu: View {

  // MARK: Lifecycle

  init(
    onAddCredential: @escaping () -> Void,
    onOrderEID: @escaping () -> Void,
    onOpenSettings: @escaping () -> Void,
    onOpenHelp: @escaping () -> Void)
  {
    isEIDRequestEnabled = Container.shared.isEIDRequestFeatureEnabled()
    self.onAddCredential = onAddCredential
    self.onOrderEID = onOrderEID
    self.onOpenSettings = onOpenSettings
    self.onOpenHelp = onOpenHelp
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case menuButton
  }

  var body: some View {
    Menu {
      credentialSection
      applicationSection
    } label: {
      Image(systemName: "ellipsis")
        .accessibilityHidden(true)
    }
    .menuOrder(.fixed)
    .contentShape(.accessibility, Circle().inset(by: -.x2))
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
    .accessibilityAddTraits(.isButton)
  }

  // MARK: Private

  private let isEIDRequestEnabled: Bool
  private let onAddCredential: () -> Void
  private let onOrderEID: () -> Void
  private let onOpenSettings: () -> Void
  private let onOpenHelp: () -> Void

  private var credentialSection: some View {
    Section {
      Button(action: onAddCredential, label: {
        Label(title: { Text(L10n.tkMenuHomeListAdd) }) { HomeAssets.menuID.swiftUIImage }
      })

      if isEIDRequestEnabled {
        Button(action: onOrderEID, label: {
          Label(title: { Text(L10n.tkMenuHomeListOrderEid) }) { HomeAssets.menuID.swiftUIImage }
        })
      }
    }
  }

  private var applicationSection: some View {
    Section {
      Button(action: onOpenSettings, label: {
        Label(title: { Text(L10n.tkMenuHomeListSettings) }) { HomeAssets.menuSettings.swiftUIImage }
      })
      .accessibilityHint(L10n.tkGlobalExternalLinkHint)

      Button(action: onOpenHelp, label: {
        Label(title: { Text(L10n.tkMenuHomeListHelp) }) { HomeAssets.menuHelp.swiftUIImage }
      })
      .accessibilityAddTraits(.isLink)
      .accessibilityHint(L10n.tkGlobalExternalLinkHint)
    }
  }
}
