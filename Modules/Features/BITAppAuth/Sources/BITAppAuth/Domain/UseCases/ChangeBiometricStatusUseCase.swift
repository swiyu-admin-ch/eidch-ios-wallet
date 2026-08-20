import BITL10n
import BITLocalAuthentication
import Factory
import Foundation
import LocalAuthentication
import Spyable

// MARK: - ChangeBiometricStatusUseCaseProtocol

@Spyable
public protocol ChangeBiometricStatusUseCaseProtocol {
  func callAsFunction(with uniquePassphrase: Data) async throws
}

// MARK: - ChangeBiometricStatusError

enum ChangeBiometricStatusError: String, Error, CustomStringConvertible {
  case userCancel
  case biometricRetry

  var description: String {
    rawValue
  }
}

// MARK: - ChangeBiometricStatusUseCase

struct ChangeBiometricStatusUseCase: ChangeBiometricStatusUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(with uniquePassphrase: Data) async throws {
    let state = getBiometricStateUseCase()

    if state == .enabled {
      try disableBiometricUseCase()
    } else {
      try await enableBiometrics(uniquePassphrase: uniquePassphrase)
    }
  }

  // MARK: Private

  @Injected(\.userSession) private var userSession: Session
  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol
  @Injected(\.requestBiometricAuthUseCase) private var requestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocol
  @Injected(\.updateBiometricUsageUseCase) private var updateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocol
  @Injected(\.disableBiometricUseCase) private var disableBiometricUseCase: DisableBiometricUseCaseProtocol
  @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol

  private func enableBiometrics(uniquePassphrase: Data) async throws {
    guard userSession.isLoggedIn, let context = userSession.context else {
      throw UserSessionError.notLoggedIn
    }

    do {
      try await requestBiometricAuthUseCase(reason: L10n.biometricSetupReason, context: context)
    } catch LAError.userCancel {
      throw ChangeBiometricStatusError.userCancel
    }

    try uniquePassphraseManager.save(uniquePassphrase: uniquePassphrase, for: .biometric, context: context)
    updateBiometricUsageUseCase(.enabled)
  }
}
