import BITAppAuth
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - SecuritySettingsView

struct SecuritySettingsView: View {

  // MARK: Internal

  var body: some View {
    SettingsPage(title: L10n.tkSettingsSecurityPrivacyTitle) {
      SettingsSection(title: L10n.tkSettingsSecurityPrivacySecuritySectionTitle) {
        SettingsItem(
          image: Assets.lock.swiftUIImage,
          title: L10n.tkSettingsSecurityPrivacySecurityChangePassword,
          type: .navigation { navigator.navigate(to: SettingsDestinations.changePassword(viewModel)) })
        SettingsItem(
          image: viewModel.biometricType.image,
          title: L10n.tkSettingsSecurityPrivacySecurityUnlock(viewModel.biometricType.text),
          detail: viewModel.biometricItemDetail,
          type: viewModel.biometricItemType,
          hasDivider: false)
      }

      SettingsSection(title: L10n.tkSettingsSecurityPrivacyDataProtectionSectionTitle) {
        SettingsItem(
          image: Assets.diagnostic.swiftUIImage,
          title: L10n.tkSettingsSecurityPrivacyDataProtectionShareDataPrimary,
          detail: L10n.tkSettingsSecurityPrivacyDataProtectionShareDataSecondary,
          type: .toggle(isOn: $viewModel.isAnalyticsEnabled, isLoading: $viewModel.isAnalyticsLoading) {
            Task {
              await viewModel.updateAnalyticsStatus()
            }
          })
        SettingsItem(
          icon: .empty,
          title: L10n.tkSettingsSecurityPrivacyDataProtectionDiagnosticData,
          type: .navigation { navigator.navigate(to: SettingsDestinations.diagnosticData) })
        SettingsItem(
          image: Assets.activityHistory.swiftUIImage,
          title: L10n.tkSettingsSecurityPrivacyDataProtectionActivityHistory,
          type: .navigation { navigator.navigate(to: SettingsDestinations.activityHistory) })
        SettingsItem(
          image: Assets.privacy.swiftUIImage,
          title: L10n.tkSettingsSecurityPrivacyDataProtectionPrivacyPolicyLinkText,
          type: .link(L10n.tkSettingsSecurityPrivacyDataProtectionPrivacyPolicyLinkValue),
          hasDivider: false)
      }
    }
    .onAppear(perform: viewModel.onAppear)
    .toast($viewModel.toast)
    .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @InjectedObservable(\.securitySettingsViewModel) private var viewModel: SecuritySettingsViewModel
}

#Preview {
  SecuritySettingsView()
}
