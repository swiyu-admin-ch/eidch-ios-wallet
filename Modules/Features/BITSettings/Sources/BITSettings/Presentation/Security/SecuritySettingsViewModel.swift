import BITAppAuth
import BITL10n
import BITTheming
import Factory
import Foundation

// MARK: - SecuritySettingsViewModel

@Observable
class SecuritySettingsViewModel {

  // MARK: Internal

  var isBiometricEnabled = false
  var biometricType = BiometricType.none

  var isAnalyticsEnabled = false

  var isAnalyticsLoading = false
  var toast: Toast?

  func onAppear() {
    fetchBiometricStatus()
    fetchAnalyticsStatus()
  }

  @MainActor
  func updateAnalyticsStatus() async {
    isAnalyticsLoading = true
    let newStatus = !isAnalyticsEnabled
    await updateAnalyticsStatusUseCase.execute(isAllowed: newStatus)

    isAnalyticsEnabled = newStatus
    isAnalyticsLoading = false
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.hasBiometricAuthUseCase) private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol
  @ObservationIgnored @Injected(\.isBiometricUsageAllowedUseCase) private var isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocol
  @ObservationIgnored @Injected(\.fetchAnalyticStatusUseCase) private var fetchAnalyticStatusUseCase: FetchAnalyticStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.updateAnalyticsStatusUseCase) private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol

  private func fetchBiometricStatus() {
    isBiometricEnabled = (isBiometricUsageAllowedUseCase.execute() && hasBiometricAuthUseCase.execute())
    biometricType = getBiometricTypeUseCase.execute()
  }

  private func fetchAnalyticsStatus() {
    isAnalyticsEnabled = fetchAnalyticStatusUseCase.execute()
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
    let biometricType = getBiometricTypeUseCase.execute()
    let message = isEnabled ? L10n.tkSettingsSecurityPrivacyStatusEnabled(biometricType.text) : L10n.tkSettingsSecurityPrivacyStatusDisabled(biometricType.text)
    toast = Toast(message)
  }
}
