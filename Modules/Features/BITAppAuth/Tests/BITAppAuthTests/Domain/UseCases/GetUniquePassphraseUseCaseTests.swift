import Factory
import Foundation
import Spyable
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITTestingCore

@Suite(.serialized)
@MainActor
struct GetUniquePassphraseUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let context = LAContextProtocolSpy()
    let pinCodeService = PinCodeServiceProtocolSpy()
    let uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()

    Container.shared.internalContext.register { context }
    Container.shared.pinCodeService.register { pinCodeService }
    Container.shared.uniquePassphraseManager.register { uniquePassphraseManager }

    self.context = context
    self.pinCodeService = pinCodeService
    self.uniquePassphraseManager = uniquePassphraseManager
    useCase = GetUniquePassphraseUseCase()
  }

  // MARK: Internal

  @Test(arguments: ["123456", "aA#$_0", "12345678901234567890"] as [PinCode])
  func happyPath(pinCode: PinCode) throws {
    try testHappyPath(pinCode: pinCode)
  }

  @Test
  func uniquePassphraseLookupFails_throwsError() {
    let mockPinCodeData = Data()
    let pinCode = "121221"

    context.setCredentialTypeReturnValue = true
    pinCodeService.encryptReturnValue = mockPinCodeData
    uniquePassphraseManager.getUniquePassphraseAuthMethodContextThrowableError = TestingError.error

    #expect(throws: TestingError.error) {
      try useCase(from: pinCode)
    }

    #expect(pinCodeService.encryptCalled)
    #expect(context.setCredentialTypeCalled)
    #expect(context.setCredentialTypeCallsCount == 1)
    #expect(pinCodeService.encryptReceivedPinCode == pinCode)
  }

  // MARK: Private

  private let useCase: GetUniquePassphraseUseCase
  private let pinCodeService: PinCodeServiceProtocolSpy
  private let uniquePassphraseManager: UniquePassphraseManagerProtocolSpy
  private let context: LAContextProtocolSpy

  private func testHappyPath(pinCode: PinCode) throws {
    let mockPinCodeData = Data()
    let mockPassphraseData = Data()

    context.setCredentialTypeReturnValue = true
    pinCodeService.encryptReturnValue = mockPinCodeData
    uniquePassphraseManager.getUniquePassphraseAuthMethodContextReturnValue = mockPassphraseData

    let passphraseData = try useCase(from: pinCode)

    #expect(passphraseData == mockPassphraseData)
    #expect(context.setCredentialTypeCalled)
    #expect(context.setCredentialTypeReceivedArguments?.credential == mockPinCodeData)

    #expect(pinCodeService.encryptCalled)
    #expect(pinCodeService.encryptReceivedPinCode == pinCode)

    #expect(context.setCredentialTypeCalled)
    #expect(context.setCredentialTypeCallsCount == 1)
  }

}
