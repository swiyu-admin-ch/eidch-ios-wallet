import BITCore
import Factory
import Foundation
import LocalAuthentication
import Spyable
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication

@Suite(.serialized)
@MainActor
struct UpdatePinCodeUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let context = LAContextProtocolSpy()
    let pinCodeService = PinCodeServiceProtocolSpy()
    let userSession = SessionSpy()
    let uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()

    Container.shared.internalContext.register { context }
    Container.shared.pinCodeService.register { pinCodeService }
    Container.shared.userSession.register { userSession }
    Container.shared.uniquePassphraseManager.register { uniquePassphraseManager }

    self.context = context
    self.pinCodeService = pinCodeService
    self.userSession = userSession
    self.uniquePassphraseManager = uniquePassphraseManager
    useCase = UpdatePinCodeUseCase()
  }

  // MARK: Internal

  @Test
  func happyPath() throws {
    let pinCodeMockData = Data()
    let uniquePassphraseMockData = Data()
    let pinCode = "123456"

    userSession.startSessionPassphraseCredentialTypeReturnValue = LAContextProtocolSpy()

    pinCodeService.encryptReturnValue = pinCodeMockData
    uniquePassphraseManager.generateReturnValue = uniquePassphraseMockData

    try useCase(with: pinCode, and: uniquePassphraseMockData)

    #expect(uniquePassphraseManager.saveUniquePassphraseForContextCalled)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextReceivedArguments?.uniquePassphrase == uniquePassphraseMockData)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextReceivedArguments?.authMethod == AuthMethod.appPin)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextCallsCount == 1)

    #expect(pinCodeService.encryptCalled)
    #expect(pinCodeService.encryptReceivedPinCode == pinCode)

    #expect(userSession.startSessionPassphraseCredentialTypeCalled)
    #expect(userSession.startSessionPassphraseCredentialTypeCallsCount == 2)
    let invocations: [(passphrase: Data, credentialType: LACredentialType)] = [
      (pinCodeMockData, .applicationPassword),
      (uniquePassphraseMockData, .applicationPassword),
    ]
    #expect(userSession.startSessionPassphraseCredentialTypeReceivedInvocations[0].passphrase == invocations[0].passphrase)
    #expect(userSession.startSessionPassphraseCredentialTypeReceivedInvocations[1].passphrase == invocations[1].passphrase)
  }

  // MARK: Private

  private let useCase: UpdatePinCodeUseCase
  private let pinCodeService: PinCodeServiceProtocolSpy
  private let uniquePassphraseManager: UniquePassphraseManagerProtocolSpy
  private let userSession: SessionSpy
  private let context: LAContextProtocolSpy
}
