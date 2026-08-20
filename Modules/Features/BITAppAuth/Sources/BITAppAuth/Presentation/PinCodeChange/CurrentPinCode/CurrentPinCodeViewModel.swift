import BITCore
import BITL10n
import Factory
import SwiftUI

@MainActor
@Observable
public class CurrentPinCodeViewModel: Vibrating {

  // MARK: Lifecycle

  init(router: ChangePinCodeInternalRoutes) {
    self.router = router

    evaluateAttempts()
  }

  // MARK: Internal

  var router: ChangePinCodeInternalRoutes

  var inputFieldMessage: String?
  var attempts = 0
  var inputFieldState = InputFieldState.normal

  var pinCode = "" {
    didSet {
      guard userDidRequestValidation else { return }
      inputFieldState = .normal
    }
  }

  var isSubmitEnabled: Bool {
    pinCode.count >= pinCodeMinimumSize
  }

  func submit() {
    do {
      userDidRequestValidation = true
      router.context.uniquePassphrase = try getUniquePassphraseUseCase(from: pinCode)
      reset()
      router.newPinCode()
    } catch {
      handleError(error)
    }
  }

  func onAppear() {
    evaluateAttempts()
  }

  // MARK: Private

  private var userDidRequestValidation = false
  @ObservationIgnored @Injected(\.getUniquePassphraseUseCase) private var getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocol
  @ObservationIgnored @Injected(\.lockWalletUseCase) private var lockWalletUseCase: LockWalletUseCaseProtocol
  @ObservationIgnored @Injected(\.registerLoginAttemptCounterUseCase) private var registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.getLoginAttemptCounterUseCase) private var getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.resetLoginAttemptCounterUseCase) private var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol
  @ObservationIgnored @Injected(\.attemptsLimit) private var attemptsLimit: Int
  @ObservationIgnored @Injected(\.pinCodeMinimumSize) private var pinCodeMinimumSize: Int

  private var attemptLeft: Int {
    attemptsLimit - attempts
  }

  private func reset() {
    try? resetLoginAttemptCounterUseCase()
    inputFieldMessage = nil
    attempts = 0
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
