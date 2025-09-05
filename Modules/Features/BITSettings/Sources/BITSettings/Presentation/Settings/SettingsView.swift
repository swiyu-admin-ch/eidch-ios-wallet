import BITAppAuth
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

  // MARK: Lifecycle

  init() {
    _viewModel = StateObject(wrappedValue: Container.shared.settingsViewModel())
  }

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
            detail: viewModel.currentLanguage,
            type: .navigation { viewModel.openLanguage() },
            hasDivider: false)
        }
        SettingsSection(title: L10n.tkSettingsGeneralSectionTitle) {
          SettingsItem(image: Assets.help.swiftUIImage, title: L10n.tkSettingsGeneralHelpLinkText, type: .link(L10n.tkSettingsGeneralHelpLinkValue))
          SettingsItem(image: Assets.feedback.swiftUIImage, title: L10n.tkSettingsGeneralFeedbackLinkText, type: .link(L10n.tkSettingsGeneralFeedbackLinkValue))
          SettingsItem(image: Assets.licenses.swiftUIImage, title: L10n.tkSettingsGeneralLicences, type: .navigation { path.append(Setting.licenses) })
          SettingsItem(image: Assets.imprint.swiftUIImage, title: L10n.tkSettingsGeneralImprint, type: .navigation { path.append(Setting.imprint) }, hasDivider: false)
        }
      }
      .navigationBar(.defaultTransparent)
      .toolbar {
        CloseButtonToolbar { dismiss() }
      }
      .onAppear(perform: viewModel.getCurrentLanguage)
      .navigationDestination(for: Setting.self) { setting in
        switch setting {
        case .security: SecuritySettingsView(path: $path)
        case .licenses: LicencesListView(path: $path)
        case .imprint: ImprintView()
        }
      }
    }
  }

  // MARK: Private

  @State private var path = NavigationPath()
  @StateObject private var viewModel: SettingsViewModel
  @Environment(\.dismiss) private var dismiss
}

// MARK: - Setting

enum Setting: Hashable {
  case security
  case licenses
  case imprint
}

#if DEBUG
#Preview {
  SettingsView()
}
#endif
