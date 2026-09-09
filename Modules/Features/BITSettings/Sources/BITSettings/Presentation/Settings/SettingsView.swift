import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

  // MARK: Internal

  var body: some View {
    SettingsPage(title: L10n.settingsScreenTitle) {
      SettingsSection(title: L10n.settingsGeneralSectionTitle) {
        SettingsItem(
          image: Assets.lock.swiftUIImage,
          title: L10n.settingsGeneralSecurityPrivacyBody,
          type: .navigation { navigator.navigate(to: SettingsDestinations.security) })

        SettingsItem(
          image: Assets.language.swiftUIImage,
          title: L10n.settingsGeneralLanguageBody,
          type: .navigation(action: viewModel.openLanguage),
          hasDivider: false)
          .accessibilityHint(L10n.tkGlobalExternalLinkHint)
      }

      SettingsSection(title: L10n.settingsHelpSectionTitle) {
        SettingsItem(
          image: Assets.help.swiftUIImage,
          title: L10n.settingsHelpContactLinkText,
          type: .link(L10n.settingsHelpContactLinkValue))

        SettingsItem(
          image: Assets.feedback.swiftUIImage,
          title: L10n.tkSettingsGeneralFeedbackLinkText,
          type: .link(L10n.tkSettingsGeneralFeedbackLinkValue),
          hasDivider: false)
      }

      SettingsSection(title: L10n.settingsLegalSectionTitle) {
        SettingsItem(
          image: Assets.accessibility.swiftUIImage,
          title: L10n.settingsLegalAccessibilityBody,
          type: .navigation { navigator.navigate(to: SettingsDestinations.accessibility) })

        SettingsItem(
          image: Assets.licenses.swiftUIImage,
          title: L10n.settingsLegalLicencesBody,
          type: .navigation { navigator.navigate(to: SettingsDestinations.licenses) })

        SettingsItem(
          image: Assets.imprint.swiftUIImage,
          title: L10n.settingsLegalLegalNoticeBody,
          type: .navigation { navigator.navigate(to: SettingsDestinations.imprint) },
          hasDivider: false)
      }

      if viewModel.isOTPDebugToggleVisible || viewModel.isLottieViewerEnabled {
        SettingsSection(title: "Debug") {

          if viewModel.isOTPDebugToggleVisible {
            SettingsItem(
              icon: .none,
              title: "Enable OTP flow",
              type: .toggle(isOn: $viewModel.isOTPEnabled) { viewModel.toggleOTPEnabled() },
              hasDivider: false)
          }

          if viewModel.isLottieViewerEnabled {
            SettingsItem(
              image: Assets.diagnostic.swiftUIImage,
              title: "Lottie animation",
              type: .navigation { navigator.navigate(to: SettingsDestinations.lottie) },
              hasDivider: false)
          }
        }
      }
    }
    .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
    .toolbar {
      CloseButtonToolbar { navigator.dismiss() }
    }
    .presentationDragIndicator(.visible)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @InjectedObservable(\.settingsViewModel) private var viewModel: SettingsViewModel
}

#if DEBUG
#Preview {
  SettingsView()
}
#endif
