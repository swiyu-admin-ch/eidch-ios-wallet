import BITCore
import BITL10n
import Factory
import SwiftUI

@MainActor
@Observable
class BiometricChangeViewModel: Vibrating {

  // MARK: Lifecycle

  init(router: BiometricChangeRouterRoutes) {
    self.router = router

    biometricType = getBiometricTypeUseCase.execute()
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

  var isBiometricEnabled = false

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
      let uniquePassphrase = try getUniquePassphraseUseCase.execute(from: pinCode)
      try await changeBiometricStatusUseCase.execute(with: uniquePassphrase)
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

  private var userDidRequestValidation = false
  @ObservationIgnored @Injected(\.getUniquePassphraseUseCase) private var getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocol
  @ObservationIgnored @Injected(\.lockWalletUseCase) private var lockWalletUseCase: LockWalletUseCaseProtocol
  @ObservationIgnored @Injected(\.registerLoginAttemptCounterUseCase) private var registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.getLoginAttemptCounterUseCase) private var getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.resetLoginAttemptCounterUseCase) private var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.attemptsLimit) private var attemptsLimit: Int

  @ObservationIgnored @Injected(\.hasBiometricAuthUseCase) private var hasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol
  @ObservationIgnored @Injected(\.changeBiometricStatusUseCase) private var changeBiometricStatusUseCase: ChangeBiometricStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.isBiometricUsageAllowedUseCase) private var isBiometricUsageAllowedUseCase: IsBiometricUsageAllowedUseCaseProtocol
  @ObservationIgnored @Injected(\.getBiometricTypeUseCase) private var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol
  @ObservationIgnored @Injected(\.pinCodeMinimumSize) private var pinCodeMinimumSize: Int

  private var attemptLeft: Int {
    attemptsLimit - attempts
  }

  private func reset() {
    try? resetLoginAttemptCounterUseCase.execute()
    inputFieldMessage = nil
    attempts = 0
  }

  private func evaluateBiometrics() {
    let hasBiometricAuth = hasBiometricAuthUseCase.execute()
    let isBiometricUsageAllowed = isBiometricUsageAllowedUseCase.execute()
    isBiometricEnabled = isBiometricUsageAllowed && hasBiometricAuth
    withAnimation {
      state = hasBiometricAuth ? .password : .disabledBiometrics
    }
  }

  private func evaluateAttempts() {
    attempts = (try? getLoginAttemptCounterUseCase.execute(kind: .appPin)) ?? 0

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
    attempts = (try? registerLoginAttemptCounterUseCase.execute(kind: .appPin)) ?? attempts + 1

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
    try? lockWalletUseCase.execute()
    NotificationCenter.default.post(name: .logout, object: nil)
  }

}
