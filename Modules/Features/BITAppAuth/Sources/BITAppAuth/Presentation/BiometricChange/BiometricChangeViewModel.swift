import BITCore
import BITL10n
import Factory
import SwiftUI

@MainActor
@Observable
final class BiometricChangeViewModel: Vibrating {

  // MARK: Lifecycle

  init(router: BiometricChangeRouterRoutes) {
    self.router = router

    biometricType = getBiometricTypeUseCase()
    evaluateBiometrics()
    evaluateAttempts()
  }

  // MARK: Internal

  enum State {
    case password
    case disabledBiometrics
  }

  var router: BiometricChangeRouterRoutes

  var inputFieldMessage: String?
  var attempts = 0
  var inputFieldState = InputFieldState.normal
  var biometricType = BiometricType.none
  var state = State.password

  var title: String {
    isBiometricEnabled ? L10n.tkSettingsSecurityPrivacyBiometricsDisablePrimary(biometricType.text) : L10n.tkSettingsSecurityPrivacyBiometricsEnablePrimary(biometricType.text)
  }

  var isSubmitEnabled: Bool {
    pinCode.count >= pinCodeMinimumSize
  }

  var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      inputFieldState = .normal
    }
  }

  @MainActor
  func submit() async {
    do {
      userDidRequestValidation = true
      let uniquePassphrase = try getUniquePassphraseUseCase(from: pinCode)
      try await changeBiometricStatusUseCase(with: uniquePassphrase)
      reset()

      evaluateBiometrics()

      router.delegate?.didBiometricStatusChange(to: isBiometricEnabled)
      router.pop()
    } catch ChangeBiometricStatusError.userCancel {
      reset()
    } catch {
      handleError(error)
    }
  }

  func onAppear() {
    evaluateBiometrics()
    evaluateAttempts()
  }

  func openSettings() {
    router.externalSettings()
  }

  // MARK: Private

  private var isBiometricEnabled = false
  private var userDidRequestValidation = false

  @ObservationIgnored @Injected(\.getUniquePassphraseUseCase) private var getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocol
  @ObservationIgnored @Injected(\.lockWalletUseCase) private var lockWalletUseCase: LockWalletUseCaseProtocol
  @ObservationIgnored @Injected(\.registerLoginAttemptCounterUseCase) private var registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.getLoginAttemptCounterUseCase) private var getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.resetLoginAttemptCounterUseCase) private var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.attemptsLimit) private var attemptsLimit: Int
  @ObservationIgnored @Injected(\.changeBiometricStatusUseCase) private var changeBiometricStatusUseCase: ChangeBiometricStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  @ObservationIgnored @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol
  @ObservationIgnored @Injected(\.pinCodeMinimumSize) private var pinCodeMinimumSize: Int

  private var attemptLeft: Int {
    attemptsLimit - attempts
  }

  private func reset() {
    try? resetLoginAttemptCounterUseCase()
    inputFieldMessage = nil
    attempts = 0
  }

  private func evaluateBiometrics() {
    let biometricState = getBiometricStateUseCase()
    isBiometricEnabled = biometricState == .enabled

    withAnimation {
      state = switch biometricState {
      case .disabled,
           .enabled:
        .password
      default:
        .disabledBiometrics
      }
    }
  }

  private func evaluateAttempts() {
    attempts = (try? getLoginAttemptCounterUseCase(kind: .appPin)) ?? 0

    var message: String? = nil
    if attemptLeft < attemptsLimit {
      message = L10n.tkChangepasswordError1Note2(attemptLeft)
    }

    withAnimation {
      if message == nil {
        inputFieldState = .normal
      }
      inputFieldMessage = message
    }
  }

  private func handleError(_ error: Error) {
    inputFieldState = .error
    attempts = (try? registerLoginAttemptCounterUseCase(kind: .appPin)) ?? attempts + 1

    if attempts >= attemptsLimit {
      return lockWallet()
    }

    let message = L10n.tkChangepasswordError1Note2(attemptLeft)
    withAnimation {
      vibrate()
      inputFieldMessage = message
    }
  }

  private func lockWallet() {
    try? lockWalletUseCase()
    NotificationCenter.default.post(name: .logout, object: nil)
  }

}
