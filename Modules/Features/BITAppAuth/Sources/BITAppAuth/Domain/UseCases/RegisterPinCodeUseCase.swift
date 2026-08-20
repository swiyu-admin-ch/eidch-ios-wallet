import BITCrypto
import BITDataStore
import BITLocalAuthentication
import Factory
import Foundation
import LocalAuthentication
import Spyable

// MARK: - RegisterPinCodeUseCaseProtocol

@Spyable
public protocol RegisterPinCodeUseCaseProtocol {
  func callAsFunction(pinCode: PinCode) throws
}

// MARK: - RegisterPinCodeUseCase

struct RegisterPinCodeUseCase: RegisterPinCodeUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(pinCode: PinCode) throws {
    let pinCodeDataEncrypted = try pinCodeService.register(pinCode)

    guard internalContext.setCredential(pinCodeDataEncrypted, type: .applicationPassword) else {
      throw AuthError.LAContextError(reason: "Register pincode context setCredential failed.")
    }

    let uniquePassphrase = try uniquePassphraseManager.generate()
    try saveUniquePassphrase(uniquePassphrase, context: internalContext)

    try userSession.startSession(passphrase: uniquePassphrase)

    dataStoreConfigurationManager.setEncryption(key: uniquePassphrase)
  }

  // MARK: Private

  @Injected(\.pinCodeService) private var pinCodeService: PinCodeServiceProtocol
  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol
  @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.dataStoreConfigurationManager) private var dataStoreConfigurationManager: DataStoreConfigurationManagerProtocol
  @Injected(\.internalContext) private var internalContext: LAContextProtocol

  private func saveUniquePassphrase(_ uniquePassphrase: Data, context: LAContextProtocol) throws {
    try uniquePassphraseManager.save(uniquePassphrase: uniquePassphrase, for: .appPin, context: context)

    if getBiometricStateUseCase() == .enabled {
      try uniquePassphraseManager.save(uniquePassphrase: uniquePassphrase, for: .biometric, context: context)
    }
  }

}
