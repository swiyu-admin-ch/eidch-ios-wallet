import Factory
import Foundation
import Spyable
import Testing
@testable import BITAppAuth
@testable import BITDataStore
@testable import BITLocalAuthentication
@testable import BITTestingCore

// MARK: - RegisterPinCodeUseCaseTests

@Suite(.serialized)
@MainActor
struct RegisterPinCodeUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let pinCodeService = PinCodeServiceProtocolSpy()
    let uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()
    let internalContext = LAContextProtocolSpy()
    let getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    let dataStoreConfiguration = DataStoreConfigurationManagerProtocolSpy()
    let userSession = SessionSpy()

    Container.shared.pinCodeService.register { pinCodeService }
    Container.shared.uniquePassphraseManager.register { uniquePassphraseManager }
    Container.shared.userSession.register { userSession }
    Container.shared.internalContext.register { internalContext }
    Container.shared.getBiometricStateUseCase.register { getBiometricStateUseCase }
    Container.shared.dataStoreConfigurationManager.register { dataStoreConfiguration }

    self.pinCodeService = pinCodeService
    self.uniquePassphraseManager = uniquePassphraseManager
    self.internalContext = internalContext
    self.getBiometricStateUseCase = getBiometricStateUseCase
    self.dataStoreConfiguration = dataStoreConfiguration
    self.userSession = userSession
    useCase = RegisterPinCodeUseCase()
  }

  // MARK: Internal

  @Test(arguments: ["123456", "aA#$_0", "12345678901234567890"] as [PinCode])
  func happyPath(pinCode: PinCode) throws {
    try testHappyPath(pinCode: pinCode)
  }

  @Test
  func validationError() {
    let pinCode: PinCode = "1"
    pinCodeService.registerThrowableError = PinCodeError.tooShort
    internalContext.setCredentialTypeReturnValue = true

    #expect(throws: PinCodeError.tooShort) {
      try useCase(pinCode: pinCode)
    }

    #expect(pinCodeService.registerCalled)
    #expect(!userSession.startSessionPassphraseCredentialTypeCalled)
    #expect(!uniquePassphraseManager.generateCalled)
    #expect(!uniquePassphraseManager.saveUniquePassphraseForContextCalled)
    #expect(!getBiometricStateUseCase.callAsFunctionCalled)
    #expect(!dataStoreConfiguration.setEncryptionKeyCalled)
  }

  // MARK: Private

  private let pinCodeService: PinCodeServiceProtocolSpy
  private let uniquePassphraseManager: UniquePassphraseManagerProtocolSpy
  private let useCase: RegisterPinCodeUseCase
  private let getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy
  private let dataStoreConfiguration: DataStoreConfigurationManagerProtocolSpy
  private let userSession: SessionSpy
  private let internalContext: LAContextProtocolSpy

}

extension RegisterPinCodeUseCaseTests {

  private func testHappyPath(pinCode: PinCode) throws {
    let mockPinCodeEncrypted = Data()
    let mockUniquePassphraseData = Data()
    internalContext.setCredentialTypeReturnValue = true
    userSession.startSessionPassphraseCredentialTypeReturnValue = LAContextProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    configureSpy(pinCodeEncrypted: mockPinCodeEncrypted, uniquePassphrase: mockUniquePassphraseData)

    try useCase(pinCode: pinCode)
    try assertResult(pinCode: pinCode, pinCodeEncrypted: mockPinCodeEncrypted, uniquePassphrase: mockUniquePassphraseData)
  }

  private func configureSpy(pinCodeEncrypted: Data, uniquePassphrase: Data) {
    pinCodeService.registerReturnValue = pinCodeEncrypted
    uniquePassphraseManager.generateReturnValue = uniquePassphrase
  }

  private func assertResult(pinCode: PinCode, pinCodeEncrypted: Data, uniquePassphrase: Data) throws {
    #expect(pinCodeService.registerCalled)
    #expect(userSession.startSessionPassphraseCredentialTypeCalled)
    #expect(uniquePassphraseManager.generateCalled)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextCalled)
    #expect(pinCodeService.registerReceivedPinCode == pinCode)
    #expect(userSession.startSessionPassphraseCredentialTypeCallsCount == 1)

    let sessionInvocation = try #require(userSession.startSessionPassphraseCredentialTypeReceivedInvocations.first)
    #expect(sessionInvocation.passphrase == pinCodeEncrypted)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextReceivedArguments?.uniquePassphrase == uniquePassphrase)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextReceivedArguments?.authMethod == AuthMethod.biometric)
    #expect(getBiometricStateUseCase.callAsFunctionCalled)

    #expect(dataStoreConfiguration.setEncryptionKeyCalled)
    #expect(dataStoreConfiguration.setEncryptionKeyCallsCount == 1)
  }

}
