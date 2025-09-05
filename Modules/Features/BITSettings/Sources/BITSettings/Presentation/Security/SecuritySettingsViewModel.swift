import BITAppAuth
import BITL10n
import Factory
import Foundation

// MARK: - SecuritySettingsViewModel

class SecuritySettingsViewModel: ObservableObject {

  // MARK: Internal

  @Published var isBiometricEnabled = false
  @Published var biometricType = BiometricType.none

  @Published var isAnalyticsEnabled = false

  @Published var isAnalyticsLoading = false
  @Published var isToastPresented = false
  @Published var toastMessage: String?

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

  func clearToast() {
    isToastPresented = false
    toastMessage = nil
  }

  // MARK: Private

  @Injected(\.hasBiometricAuthUseCase) private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol
  @Injected(\.isBiometricUsageAllowedUseCase) private var isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocol
  @Injected(\.fetchAnalyticStatusUseCase) private var fetchAnalyticStatusUseCase: FetchAnalyticStatusUseCaseProtocol
  @Injected(\.updateAnalyticsStatusUseCase) private var updateAnalyticsStatusUseCase: UpdateAnalyticStatusUseCaseProtocol
  @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol

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
    toastMessage = L10n.tkChangepasswordSuccessfulNotification
    isToastPresented = true
  }
}

// MARK: BiometricChangeDelegate

extension SecuritySettingsViewModel: BiometricChangeDelegate {

  func didBiometricStatusChange(to isEnabled: Bool) {
    let biometricType = getBiometricTypeUseCase.execute()
    toastMessage = isEnabled ? L10n.tkSettingsSecurityPrivacyStatusEnabled(biometricType.text) : L10n.tkSettingsSecurityPrivacyStatusDisabled(biometricType.text)
    isToastPresented = true
  }
}
