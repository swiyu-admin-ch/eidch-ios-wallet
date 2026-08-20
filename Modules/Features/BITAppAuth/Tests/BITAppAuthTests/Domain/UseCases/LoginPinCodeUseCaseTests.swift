import BITCore
import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITAppAuth
@testable import BITDataStore
@testable import BITLocalAuthentication
@testable import BITTestingCore

@Suite(.container)
struct LoginPinCodeUseCaseTests {

  // MARK: Lifecycle

  init() {
    let getUniquePassphraseUseCase = GetUniquePassphraseUseCaseProtocolSpy()
    self.getUniquePassphraseUseCase = getUniquePassphraseUseCase

    let isBiometricInvalidatedUseCase = IsBiometricInvalidatedUseCaseProtocolSpy()
    self.isBiometricInvalidatedUseCase = isBiometricInvalidatedUseCase

    let disableBiometricUseCase = DisableBiometricUseCaseProtocolSpy()
    self.disableBiometricUseCase = disableBiometricUseCase

    let userSession = SessionSpy()
    self.userSession = userSession

    let dataStoreConfiguration = DataStoreConfigurationManagerProtocolSpy()
    self.dataStoreConfiguration = dataStoreConfiguration

    Container.shared.getUniquePassphraseUseCase.register { getUniquePassphraseUseCase }
    Container.shared.isBiometricInvalidatedUseCase.register { isBiometricInvalidatedUseCase }
    Container.shared.disableBiometricUseCase.register { disableBiometricUseCase }
    Container.shared.userSession.register { userSession }
    Container.shared.dataStoreConfigurationManager.register { dataStoreConfiguration }

    userSession.startSessionPassphraseCredentialTypeReturnValue = LAContextProtocolSpy()
    getUniquePassphraseUseCase.callAsFunctionFromReturnValue = mockUniquePassphrase

    useCase = LoginPinCodeUseCase()
  }

  // MARK: Internal

  @Test
  func login_biometricsValid_keepsBiometricsUntouched() throws {
    isBiometricInvalidatedUseCase.callAsFunctionReturnValue = false

    try useCase(from: mockPinCode)

    #expect(getUniquePassphraseUseCase.callAsFunctionFromReceivedPinCode == mockPinCode)
    #expect(isBiometricInvalidatedUseCase.callAsFunctionCalled)
    #expect(!disableBiometricUseCase.callAsFunctionCalled)
    #expect(dataStoreConfiguration.setEncryptionKeyCallsCount == 1)
    #expect(userSession.startSessionPassphraseCredentialTypeCallsCount == 1)
  }

  @Test
  func login_biometricsInvalidated_disablesBiometrics() throws {
    isBiometricInvalidatedUseCase.callAsFunctionReturnValue = true

    try useCase(from: mockPinCode)

    #expect(isBiometricInvalidatedUseCase.callAsFunctionCalled)
    #expect(disableBiometricUseCase.callAsFunctionCalled)
    #expect(dataStoreConfiguration.setEncryptionKeyCallsCount == 1)
    #expect(userSession.startSessionPassphraseCredentialTypeCallsCount == 1)
  }

  @Test
  func login_biometricsInvalidated_disableThrows_isIgnoredAndLoginSucceeds() throws {
    isBiometricInvalidatedUseCase.callAsFunctionReturnValue = true
    disableBiometricUseCase.callAsFunctionThrowableError = TestingError.error

    try useCase(from: mockPinCode)

    #expect(disableBiometricUseCase.callAsFunctionCalled)
    #expect(dataStoreConfiguration.setEncryptionKeyCallsCount == 1)
  }

  // MARK: Private

  private let useCase: LoginPinCodeUseCase
  private let getUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocolSpy
  private let isBiometricInvalidatedUseCase: IsBiometricInvalidatedUseCaseProtocolSpy
  private let disableBiometricUseCase: DisableBiometricUseCaseProtocolSpy
  private let userSession: SessionSpy
  private let dataStoreConfiguration: DataStoreConfigurationManagerProtocolSpy

  private let mockPinCode = "123456"
  private let mockUniquePassphrase = Data()

}
