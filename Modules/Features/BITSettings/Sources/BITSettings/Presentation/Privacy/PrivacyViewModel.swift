import BITAppAuth
import BITL10n
import Factory
import Foundation

// MARK: - PrivacyViewModel

class PrivacyViewModel: ObservableObject {

  // MARK: Lifecycle

  init(
    hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol = Container.shared.hasBiometricAuthUseCase(),
    isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocol = Container.shared.isBiometricUsageAllowedUseCase(),
    updateAnalyticStatusUseCase: UpdateAnalyticStatusUseCaseProtocol = Container.shared.updateAnalyticsStatusUseCase(),
    fetchAnalyticStatusUseCase: FetchAnalyticStatusUseCaseProtocol = Container.shared.fetchAnalyticStatusUseCase(),
    getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol = Container.shared.getBiometricTypeUseCase())
  {
    self.hasBiometricAuthUseCase = hasBiometricAuthUseCase
    self.isBiometricUsageAllowedUseCase = isBiometricUsageAllowedUseCase
    self.updateAnalyticStatusUseCase = updateAnalyticStatusUseCase
    self.fetchAnalyticStatusUseCase = fetchAnalyticStatusUseCase
    self.getBiometricTypeUseCase = getBiometricTypeUseCase
  }

  // MARK: Internal

  @Published var isBiometricEnabled = false
  @Published var isAnalyticsEnabled = false

  @Published var isChangePinCodePresented = false
  @Published var isInformationPresented = false
  @Published var isBiometricChangeFlowPresented = false

  @Published var isLoading = false
  @Published var isToastPresented = false
  @Published var toastMessage: String?

  func fetchBiometricStatus() {
    isBiometricEnabled = (isBiometricUsageAllowedUseCase.execute() && hasBiometricAuthUseCase.execute())
  }

  func fetchAnalyticsStatus() {
    isAnalyticsEnabled = fetchAnalyticStatusUseCase.execute()
  }

  func presentPinChangeFlow() {
    isChangePinCodePresented = true
  }

  func presentBiometricChangeFlow() {
    isBiometricChangeFlowPresented = true
  }

  func presentInformationView() {
    isInformationPresented = true
  }

  @MainActor
  func updateAnalyticsStatus() async {
    isLoading = true
    let newStatus = !isAnalyticsEnabled
    await updateAnalyticStatusUseCase.execute(isAllowed: newStatus)

    isAnalyticsEnabled = newStatus
    isLoading = false
  }

  func clearToast() {
    toastMessage = nil
  }

  // MARK: Private

  private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol
  private var isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocol
  private var fetchAnalyticStatusUseCase: FetchAnalyticStatusUseCaseProtocol
  private var updateAnalyticStatusUseCase: UpdateAnalyticStatusUseCaseProtocol
  private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol

}

// MARK: ChangePinCodeDelegate

extension PrivacyViewModel: ChangePinCodeDelegate {

  func didChangePinCode() {
    toastMessage = L10n.tkChangepasswordSuccessfulNotification
    isToastPresented = true
  }

}

// MARK: BiometricChangeDelegate

extension PrivacyViewModel: BiometricChangeDelegate {

  func didBiometricStatusChange(to isEnabled: Bool) {
    let biometricType = getBiometricTypeUseCase.execute()
    toastMessage = isEnabled ? L10n.tkMenuSecurityPrivacyIosStatusActivating(biometricType.text) : L10n.tkMenuSecurityPrivacyIosStatusDeactivating(biometricType.text)
    isToastPresented = true
  }

}
