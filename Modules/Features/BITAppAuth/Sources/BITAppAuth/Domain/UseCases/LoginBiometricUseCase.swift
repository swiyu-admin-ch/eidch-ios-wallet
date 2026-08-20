import BITDataStore
import BITL10n
import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - LoginBiometricUseCaseProtocol

@Spyable
public protocol LoginBiometricUseCaseProtocol {
  func callAsFunction() async throws
}

// MARK: - LoginBiometricUseCase

class LoginBiometricUseCase: LoginBiometricUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() async throws {
    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
    do {
      guard try await internalContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: L10n.biometricSetupReason) else {
        throw AuthError.LAContextError(reason: "Cannot evaluate policy for `deviceOwnerAuthenticationWithBiometrics`")
      }
      let uniquePassphrase = try uniquePassphraseManager.getUniquePassphrase(authMethod: .biometric, context: internalContext)
      try userSession.startSession(passphrase: uniquePassphrase)
      dataStoreConfigurationManager.setEncryption(key: uniquePassphrase)

      NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
      NotificationCenter.default.post(name: .didLogin, object: nil)
    } catch {
      NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
      throw error
    }
  }

  // MARK: Private

  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol
  @Injected(\.dataStoreConfigurationManager) private var dataStoreConfigurationManager: DataStoreConfigurationManagerProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.internalContext) private var internalContext: LAContextProtocol
}
