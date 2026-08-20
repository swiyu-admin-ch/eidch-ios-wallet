import BITAppAuth
import BITCore
import BITL10n
import BITLocalAuthentication
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - SecuritySettingsViewModel

@Observable
final class SecuritySettingsViewModel {

  // MARK: Internal

  var biometricType = BiometricType.none
  var biometricUsage = BiometricState.disabled

  var toast: Toast?
  var isAnalyticsEnabled = false
  var isAnalyticsLoading = false
  var destination: SettingsDestinations?

  var isBiometricEnabled: Bool {
    biometricUsage == .enabled
  }

  var biometricItemDetail: String? {
    switch biometricUsage {
    case .disabled,
         .enabled: nil
    case .declined: L10n.tkSettingsSecurityPrivacySecurityDisableBiometricDetail(biometricType.text, biometricType.text)
    case .notEnrolled: L10n.tkSettingsSecurityPrivacySecurityNotEnrollBiometricDetail(biometricType.text, biometricType.text)
    }
  }

  var biometricItemType: SettingsItemType {
    switch biometricUsage {
    case .disabled,
         .enabled: .toggle(isOn: .constant(isBiometricEnabled)) {
        self.destination = .biometrics(self)
      }
    case .notEnrolled:
      .navigation {
        self.toast = Toast(L10n.tkSettingsSecurityPrivacySecurityBiometricNotEnrolledToast(self.biometricType.text))
      }
    case .declined:
      .navigation(action: openSettings)
    }
  }

  func onAppear() {
    fetchBiometricStatus()
    fetchAnalyticsStatus()
  }

  @MainActor
  func updateAnalyticsStatus() async {
    isAnalyticsLoading = true
    let newStatus = !isAnalyticsEnabled
    await updateAnalyticsStatusUseCase(isAllowed: newStatus)

    isAnalyticsEnabled = newStatus
    isAnalyticsLoading = false
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.isAnalyticsEnabledUseCase) private var isAnalyticsEnabledUseCase: IsAnalyticsEnabledUseCaseProtocol
  @ObservationIgnored @Injected(\.updateAnalyticsStatusUseCase) private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol
  @ObservationIgnored @Injected(\.internalContext) private var context: LAContextProtocol
  @ObservationIgnored @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  @ObservationIgnored @Injected(\.applicationService) private var applicationService

  private func fetchBiometricStatus() {
    biometricUsage = getBiometricStateUseCase()
    biometricType = getBiometricTypeUseCase()
  }

  private func fetchAnalyticsStatus() {
    isAnalyticsEnabled = isAnalyticsEnabledUseCase()
  }

  private func openSettings() {
    Task {
      guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
        return
      }

      await applicationService.open(settingsUrl)
    }
  }
}

// MARK: ChangePinCodeDelegate

extension SecuritySettingsViewModel: ChangePinCodeDelegate {

  func didChangePinCode() {
    toast = Toast(L10n.tkChangepasswordSuccessfulNotification)
  }
}

// MARK: BiometricChangeDelegate

extension SecuritySettingsViewModel: BiometricChangeDelegate {

  func didBiometricStatusChange(to isEnabled: Bool) {
    let biometricType = getBiometricTypeUseCase()
    let message = isEnabled ? L10n.tkSettingsSecurityPrivacyStatusEnabled(biometricType.text) : L10n.tkSettingsSecurityPrivacyStatusDisabled(biometricType.text)
    toast = Toast(message)
  }
}
