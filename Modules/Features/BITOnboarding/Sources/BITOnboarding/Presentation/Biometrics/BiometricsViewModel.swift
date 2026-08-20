import BITAnalytics
import BITAppAuth
import BITL10n
import BITLocalAuthentication
import BITSettings
import Factory
import Foundation
import SwiftUI

@MainActor
@Observable
final class BiometricsViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router

    biometricType = getBiometricTypeUseCase()
    hasBiometricAuth = hasBiometricAuthUseCase()

    configureObservers()
  }

  // MARK: Internal

  var error: Error?
  var isErrorPresented = false
  var biometricType = BiometricType.none

  @ObservationIgnored @Injected(\.autoHideErrorDelay) var autoHideErrorDelay: Double

  var hasBiometricAuth = false

  var primaryText: String {
    L10n.tkOnboardingBiometricsPermissionPrimary(biometricType.text)
  }

  var secondaryText: String {
    L10n.tkOnboardingBiometricsPermissionSecondary(biometricType.text)
  }

  var tertiaryText: String {
    L10n.tkOnboardingBiometricsPermissionTertiary(biometricType.text)
  }

  var image: Image {
    biometricType.image
  }

  func primaryAction() async {
    guard hasBiometricAuth else {
      return router.setup()
    }

    await registerBiometrics()
  }

  func registerBiometrics() async {
    do {
      try await requestBiometricAuthUseCase(reason: L10n.tkOnboardingBiometricsPermissionReason, context: internalLAContext)
      updateBiometricUsageUseCase(.enabled)

      router.setup()
    } catch {
      if let authError = error as? AuthError, authError == .biometricNotAvailable {
        updateBiometricUsageUseCase(.declined)
        return router.setup()
      }

      handleError(error)
      analytics.log(AnalyticsEvent.biometricRegistrationFailed)
    }
  }

  func hideError() {
    isErrorPresented = false
  }

  func checkBiometricStatus() {
    hasBiometricAuth = hasBiometricAuthUseCase()
    biometricType = getBiometricTypeUseCase()
  }

  // MARK: Private

  private enum AnalyticsEvent: Error {
    case biometricRegistrationFailed
  }

  private let router: OnboardingInternalRoutes

  @ObservationIgnored @Injected(\.internalLAContext) private var internalLAContext: LAContextProtocol
  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.hasBiometricAuthUseCase) private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol
  @ObservationIgnored @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol
  @ObservationIgnored @Injected(\.requestBiometricAuthUseCase) private var requestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocol
  @ObservationIgnored @Injected(\.updateBiometricUsageUseCase) private var updateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocol

  private func configureObservers() {
    NotificationCenter.default.addObserver(forName: .willEnterForeground, object: nil, queue: .main) { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.checkBiometricStatus()
      }
    }
  }

  private func handleError(_ error: Error) {
    self.error = error

    if let authError = error as? AuthError, authError == .biometricNotAvailable {
      updateBiometricUsageUseCase(.declined)
    }

    isErrorPresented = true
  }
}
