import BITAppAuth
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - SecuritySettingsView

struct SecuritySettingsView: View {

  // MARK: Lifecycle

  init(path: Binding<NavigationPath>) {
    _path = path
    _viewModel = StateObject(wrappedValue: Container.shared.securitySettingsViewModel())
  }

  // MARK: Internal

  var body: some View {
    SettingsPage(title: L10n.tkSettingsSecurityPrivacyTitle) {
      SettingsSection(title: L10n.tkSettingsSecurityPrivacySecuritySectionTitle) {
        SettingsItem(image: Assets.lock.swiftUIImage, title: L10n.tkSettingsSecurityPrivacySecurityChangePassword, type: .navigation { path.append(SecuritySettings.password) })
        SettingsItem(
          image: viewModel.biometricType.image,
          title: L10n.tkSettingsSecurityPrivacySecurityUnlock(viewModel.biometricType.text),
          type: .toggle(isOn: $viewModel.isBiometricEnabled) { path.append(SecuritySettings.biometrics) },
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
        SettingsItem(icon: .empty, title: L10n.tkSettingsSecurityPrivacyDataProtectionDiagnosticData, type: .navigation { path.append(SecuritySettings.diagnosticData) })
        SettingsItem(
          image: Assets.activityHistory.swiftUIImage,
          title: L10n.tkSettingsSecurityPrivacyDataProtectionActivityHistory,
          type: .navigation { path.append(SecuritySettings.activityHistory) })
        SettingsItem(
          image: Assets.privacy.swiftUIImage,
          title: L10n.tkSettingsSecurityPrivacyDataProtectionPrivacyPolicyLinkText,
          type: .link(L10n.tkSettingsSecurityPrivacyDataProtectionPrivacyPolicyLinkValue),
          hasDivider: false)
      }
    }
    .onAppear(perform: viewModel.onAppear)
    .navigationDestination(for: SecuritySettings.self) { setting in
      switch setting {
      case .password:
        ChangePinCodeModuleWrapper(delegate: viewModel)
          .edgesIgnoringSafeArea(.all)
      case .biometrics:
        BiometricChangeModuleWrapper(delegate: viewModel)
          .edgesIgnoringSafeArea(.all)
      case .activityHistory: ActivityHistorySettingsView()
      case .diagnosticData: DiagnosticDataSettingsView()
      }
    }
    .toastMessage(
      isPresented: $viewModel.isToastPresented,
      message: viewModel.toastMessage,
      clearAction: viewModel.clearToast)
  }

  // MARK: Private

  @Binding private var path: NavigationPath
  @StateObject private var viewModel: SecuritySettingsViewModel
}

// MARK: - SecuritySettings

enum SecuritySettings: Hashable {
  case password
  case biometrics
  case diagnosticData
  case activityHistory
}

#Preview {
  SecuritySettingsView(path: .constant(NavigationPath()))
}
