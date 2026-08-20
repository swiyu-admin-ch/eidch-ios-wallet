import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

  // MARK: Internal

  var body: some View {
    SettingsPage(title: L10n.tkSettingsTitle) {
      SettingsSection(title: L10n.tkSettingsWalletSectionTitle) {
        SettingsItem(
          image: Assets.lock.swiftUIImage,
          title: L10n.tkSettingsWalletSecurityPrivacy,
          type: .navigation { navigator.navigate(to: SettingsDestinations.security) })

        SettingsItem(
          image: Assets.language.swiftUIImage,
          title: L10n.tkSettingsWalletLanguage,
          type: .navigation(action: viewModel.openLanguage),
          hasDivider: false)
          .accessibilityHint(L10n.tkGlobalExternalLinkHint)
      }

      SettingsSection(title: L10n.tkSettingsFeedbackSupportSectionTitle) {
        SettingsItem(
          image: Assets.help.swiftUIImage,
          title: L10n.tkSettingsGeneralHelpLinkText,
          type: .link(L10n.tkSettingsGeneralHelpLinkValue))

        SettingsItem(
          image: Assets.feedback.swiftUIImage,
          title: L10n.tkSettingsGeneralFeedbackLinkText,
          type: .link(L10n.tkSettingsGeneralFeedbackLinkValue),
          hasDivider: false)
      }

      SettingsSection(title: L10n.tkSettingsGeneralSectionTitle) {
        SettingsItem(
          image: Assets.accessibility.swiftUIImage,
          title: L10n.tkSettingsGeneralAccessibility,
          type: .navigation { navigator.navigate(to: SettingsDestinations.accessibility) })

        SettingsItem(
          image: Assets.licenses.swiftUIImage,
          title: L10n.tkSettingsGeneralLicences,
          type: .navigation { navigator.navigate(to: SettingsDestinations.licenses) })

        SettingsItem(
          image: Assets.imprint.swiftUIImage,
          title: L10n.tkSettingsGeneralImprint,
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
