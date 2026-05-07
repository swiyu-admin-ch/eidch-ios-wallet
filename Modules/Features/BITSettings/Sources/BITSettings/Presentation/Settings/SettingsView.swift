import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

  // MARK: Internal

  var body: some View {
    NavigationStack(path: $path) {
      SettingsPage(title: L10n.tkSettingsTitle) {
        SettingsSection(title: L10n.tkSettingsWalletSectionTitle) {
          SettingsItem(
            image: Assets.lock.swiftUIImage,
            title: L10n.tkSettingsWalletSecurityPrivacy,
            type: .navigation { path.append(Setting.security) })
          SettingsItem(
            image: Assets.language.swiftUIImage,
            title: L10n.tkSettingsWalletLanguage,
            type: .navigation { viewModel.openLanguage() },
            hasDivider: false)
        }
        SettingsSection(title: L10n.tkSettingsGeneralSectionTitle) {
          SettingsItem(image: Assets.help.swiftUIImage, title: L10n.tkSettingsGeneralHelpLinkText, type: .link(L10n.tkSettingsGeneralHelpLinkValue))
          SettingsItem(image: Assets.feedback.swiftUIImage, title: L10n.tkSettingsGeneralFeedbackLinkText, type: .link(L10n.tkSettingsGeneralFeedbackLinkValue))
          SettingsItem(image: Assets.licenses.swiftUIImage, title: L10n.tkSettingsGeneralLicences, type: .navigation { path.append(Setting.licenses) })
          SettingsItem(image: Assets.imprint.swiftUIImage, title: L10n.tkSettingsGeneralImprint, type: .navigation { path.append(Setting.imprint) }, hasDivider: false)
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
              SettingsItem(image: Assets.diagnostic.swiftUIImage, title: "Lottie animation", type: .navigation { path.append(Setting.lottie) }, hasDivider: false)
            }
          }
        }
      }
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .toolbar {
        CloseButtonToolbar { dismiss() }
      }
      .navigationDestination(for: Setting.self) { setting in
        switch setting {
        case .security: SecuritySettingsView(path: $path)
        case .licenses: LicencesListView(path: $path)
        case .imprint: ImprintView()
        case .lottie: LottieViewer()
        }
      }
    }
  }

  // MARK: Private

  @State private var path = NavigationPath()
  @Environment(\.dismiss) private var dismiss

  @InjectedObservable(\.settingsViewModel) private var viewModel: SettingsViewModel
}

// MARK: - Setting

enum Setting: Hashable {
  case security
  case licenses
  case imprint
  case lottie
}

#if DEBUG
#Preview {
  SettingsView()
}
#endif
