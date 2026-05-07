import BITOTP
import Factory
import SwiftUI

// MARK: - SettingsViewModel

@Observable
class SettingsViewModel {

  // MARK: Lifecycle

  init() {
    syncOTPDebugToggleState()
  }

  // MARK: Internal

  var isOTPDebugToggleVisible = false
  var isOTPEnabled = false

  @ObservationIgnored @Injected(\.isLottieViewerEnabled) var isLottieViewerEnabled: Bool

  func openLanguage() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  func toggleOTPEnabled() {
    guard isOTPDebugToggleVisible else { return }
    isOTPEnabled.toggle()
    setOTPEnabledUseCase(isOTPEnabled)
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.isOTPDebugToggleEnabled) private var isOTPDebugToggleEnabled: Bool
  @ObservationIgnored @Injected(\.isOTPEnabledUseCase) private var isOTPEnabledUseCase: IsOTPEnabledUseCaseProtocol
  @ObservationIgnored @Injected(\.setOTPEnabledUseCase) private var setOTPEnabledUseCase: SetOTPEnabledUseCaseProtocol

  private func syncOTPDebugToggleState() {
    isOTPDebugToggleVisible = isOTPDebugToggleEnabled
    isOTPEnabled = isOTPDebugToggleVisible ? isOTPEnabledUseCase() : false
  }
}
