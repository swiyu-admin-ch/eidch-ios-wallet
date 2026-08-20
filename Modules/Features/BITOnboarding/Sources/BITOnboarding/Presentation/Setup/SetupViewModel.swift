import BITAppAuth
import BITCore
import BITSettings
import Combine
import Factory
import Foundation
import SwiftUI

// MARK: - SetupViewModel

@MainActor
@Observable
class SetupViewModel {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @ObservationIgnored @AppStorage(UserDefaultsKey.rootOnboardingIsEnabled.rawValue) var isOnboardingEnabled = true

  var isAnimating = true

  func run() async {
    do {
      withAnimation {
        isAnimating = true
      }
      try await Task.sleep(nanoseconds: 2_000_000_000)
      guard let pincode = router.context.pincode else { throw SetupError.missingPinCode }
      try registerPinCodeUseCase(pinCode: pincode)
      await updateAnalyticsStatusUseCase(isAllowed: router.context.analyticsOptIn)
      try setActivityHistoryEnabledUseCase(true)
      isOnboardingEnabled = false
      try await Task.sleep(nanoseconds: 2_000_000_000)
      router.completed()
    } catch {
      isAnimating = false
      router.setupError(delegate: self)
    }
  }

  // MARK: Private

  private enum SetupError: Error {
    case missingPinCode
  }

  private let router: OnboardingInternalRoutes
  @ObservationIgnored @Injected(\.registerPinCodeUseCase) private var registerPinCodeUseCase
  @ObservationIgnored @Injected(\.updateAnalyticsStatusUseCase) private var updateAnalyticsStatusUseCase
  @ObservationIgnored @Injected(\.setActivityHistoryEnabledUseCase) private var setActivityHistoryEnabledUseCase

}

// MARK: SetupDelegate

@MainActor
extension SetupViewModel: SetupDelegate {

  func restartSetup() {
    Task { await run() }
  }

}

// MARK: - SetupDelegate

@MainActor
protocol SetupDelegate: AnyObject {
  func restartSetup()
}
