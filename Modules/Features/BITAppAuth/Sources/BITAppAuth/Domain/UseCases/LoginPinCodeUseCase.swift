import BITDataStore
import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - LoginPinCodeUseCaseProtocol

@Spyable
public protocol LoginPinCodeUseCaseProtocol {
  func callAsFunction(from pinCode: PinCode) throws
}

// MARK: - LoginPinCodeUseCase

struct LoginPinCodeUseCase: LoginPinCodeUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(from pinCode: PinCode) throws {
    let uniquePassphrase = try getUniquePassphraseUseCase(from: pinCode)
    try userSession.startSession(passphrase: uniquePassphrase)

    if isBiometricInvalidatedUseCase() {
      try? disableBiometricUseCase()
    }
    dataStoreConfigurationManager.setEncryption(key: uniquePassphrase)

    NotificationCenter.default.post(name: .didLogin, object: nil)
  }

  // MARK: Private

  @Injected(\.getUniquePassphraseUseCase) private var getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocol
  @Injected(\.isBiometricInvalidatedUseCase) private var isBiometricInvalidatedUseCase: IsBiometricInvalidatedUseCaseProtocol
  @Injected(\.disableBiometricUseCase) private var disableBiometricUseCase: DisableBiometricUseCaseProtocol
  @Injected(\.dataStoreConfigurationManager) private var dataStoreConfigurationManager: DataStoreConfigurationManagerProtocol
  @Injected(\.userSession) private var userSession: Session
}
