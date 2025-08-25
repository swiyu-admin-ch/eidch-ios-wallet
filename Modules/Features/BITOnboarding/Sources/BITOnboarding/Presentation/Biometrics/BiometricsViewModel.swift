import BITAnalytics
import BITAppAuth
import BITL10n
import BITLocalAuthentication
import BITSettings
import Factory
import Foundation
import SwiftUI

// MARK: - BiometricsViewModel

@MainActor
class BiometricsViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router

    biometricType = getBiometricTypeUseCase.execute()
    hasBiometricAuth = hasBiometricAuthUseCase.execute()

    configureObservers()
  }

  // MARK: Internal

  enum AnalyticsEvent: Error {
    case biometricRegistrationFailed
  }

  @Published var hasBiometricAuth = false
  var biometricType = BiometricType.none

  @Published var error: Error?
  @Published var isErrorPresented = false

  @Injected(\.autoHideErrorDelay) var autoHideErrorDelay: Double

  var primaryText: String {
    hasBiometricAuth ? L10n.tkOnboardingBiometricsPermissionPrimary(biometricType.text) : L10n.tkOnboardingBiometricsPermissionDisabledPrimary(biometricType.text)
  }

  var secondaryText: String {
    hasBiometricAuth ? L10n.tkOnboardingBiometricsPermissionSecondary(biometricType.text) : L10n.tkOnboardingBiometricsPermissionDisabledSecondary(biometricType.text)
  }

  var tertiaryText: String {
    hasBiometricAuth ? L10n.tkOnboardingBiometricsPermissionTertiary(biometricType.text) : L10n.tkOnboardingBiometricsPermissionDisabledTertiary(biometricType.text)
  }

  var image: Image {
    biometricType.image
  }

  func skip() {
    router.setup()
  }

  func registerBiometrics() async {
    do {
      try await requestBiometricAuthUseCase.execute(reason: L10n.tkOnboardingBiometricsPermissionReason, context: internalLAContext)
      try allowBiometricUsageUseCase.execute(allow: true)

      router.setup()
    } catch {
      handleError(error)
      analytics.log(AnalyticsEvent.biometricRegistrationFailed)
    }
  }

  func openSettings() {
    router.settings()
  }

  func hideError() {
    isErrorPresented = false
  }

  // MARK: Private

  private let router: OnboardingInternalRoutes
  @Injected(\.internalLAContext) private var internalLAContext: LAContextProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.hasBiometricAuthUseCase) private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol
  @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol
  @Injected(\.requestBiometricAuthUseCase) private var requestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocol
  @Injected(\.allowBiometricUsageUseCase) private var allowBiometricUsageUseCase: AllowBiometricUsageUseCaseProtocol

  private func configureObservers() {
    NotificationCenter.default.addObserver(forName: .willEnterForeground, object: nil, queue: .main) { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.checkBiometricStatus()
      }
    }
  }

  private func checkBiometricStatus() {
    hasBiometricAuth = hasBiometricAuthUseCase.execute()
    biometricType = getBiometricTypeUseCase.execute()
  }

  private func handleError(_ error: Error) {
    self.error = error
    isErrorPresented = true
  }

}
