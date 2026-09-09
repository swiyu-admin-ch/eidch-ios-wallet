import BITEIDRequest
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - HomeMenu

struct HomeMenu: View {

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case menuButton
  }

  var body: some View {
    Menu {
      if isBetaIdEnabled || isEIDRequestEnabled {
        credentialSection
      }
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

  @Environment(\.navigator) private var navigator
  @Environment(\.openURL) private var openURL

  @Injected(\.isEIDRequestFeatureEnabled) private var isEIDRequestEnabled
  @Injected(\.isBetaIdEnabled) private var isBetaIdEnabled

  private var credentialSection: some View {
    Section {
      if isBetaIdEnabled {
        Button(
          action: { navigator.navigate(to: HomeDestinations.external(.betaId)) },
          label: {
            Label(title: { Text(L10n.menuOrderBetaIdBody) }) { HomeAssets.menuID.swiftUIImage }
          })
      }

      if isEIDRequestEnabled {
        Button(
          action: { navigator.navigate(to: HomeDestinations.external(.eIDRequest)) },
          label: {
            Label(title: { Text(L10n.menuOrderEidBody) }) { HomeAssets.menuID.swiftUIImage }
          })
      }
    }
  }

  private var applicationSection: some View {
    Section {
      Button(
        action: {
          navigator.navigate(to: HomeDestinations.external(.settings))
        },
        label: {
          Label(title: { Text(L10n.menuSettingsBody) }) { HomeAssets.menuSettings.swiftUIImage }
        })
        .accessibilityHint(L10n.tkGlobalExternalLinkHint)

      Button(
        action: {
          openExternalURL(URL(string: L10n.settingsHelpContactLinkValue))
        },
        label: {
          Label(title: { Text(L10n.menuHelpBody) }) { HomeAssets.menuHelp.swiftUIImage }
        })
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(L10n.tkGlobalExternalLinkHint)
    }
  }

  private func openExternalURL(_ url: URL?) {
    guard let url else { return }

    openURL(url)
  }
}
