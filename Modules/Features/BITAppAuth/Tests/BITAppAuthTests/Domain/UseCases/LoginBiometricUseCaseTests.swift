import BITCore
import BITVault
import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITDataStore
@testable import BITLocalAuthentication

// MARK: - LoginBiometricUseCaseTests

final class LoginBiometricUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()
    userSession = SessionSpy()
    context = LAContextProtocolSpy()
    dataStoreConfiguration = DataStoreConfigurationManagerProtocolSpy()

    Container.shared.uniquePassphraseManager.register { self.uniquePassphraseManager }
    Container.shared.dataStoreConfigurationManager.register { self.dataStoreConfiguration }
    Container.shared.internalContext.register { self.context }
    Container.shared.userSession.register { self.userSession }

    useCase = LoginBiometricUseCase()
  }

  func testHappyPath() async throws {
    let mockUniquePassphraseData = Data()
    userSession.startSessionPassphraseCredentialTypeReturnValue = context
    context.evaluatePolicyLocalizedReasonReturnValue = true
    uniquePassphraseManager.getUniquePassphraseAuthMethodContextReturnValue = mockUniquePassphraseData

    let didLoginNotification = expectation(forNotification: .didLogin, object: nil)

    try await useCase()
    XCTAssertTrue(context.evaluatePolicyLocalizedReasonCalled)
    XCTAssertTrue(uniquePassphraseManager.getUniquePassphraseAuthMethodContextCalled)
    XCTAssertTrue(userSession.startSessionPassphraseCredentialTypeCalled)

    XCTAssertEqual(AuthMethod.biometric, uniquePassphraseManager.getUniquePassphraseAuthMethodContextReceivedArguments?.authMethod)
    XCTAssertEqual(mockUniquePassphraseData, userSession.startSessionPassphraseCredentialTypeReceivedArguments?.passphrase)

    XCTAssertTrue(dataStoreConfiguration.setEncryptionKeyCalled)
    XCTAssertEqual(dataStoreConfiguration.setEncryptionKeyCallsCount, 1)

    await fulfillment(of: [didLoginNotification], timeout: 2)
  }

  func testBiometricsUseCaseError() async throws {
    context.evaluatePolicyLocalizedReasonReturnValue = false
    do {
      try await useCase()
      XCTFail("Should fail instead...")
    } catch AuthError.LAContextError {
      XCTAssertTrue(context.evaluatePolicyLocalizedReasonCalled)
      XCTAssertFalse(uniquePassphraseManager.getUniquePassphraseAuthMethodContextCalled)
      XCTAssertFalse(userSession.startSessionPassphraseCredentialTypeCalled)
      XCTAssertFalse(dataStoreConfiguration.setEncryptionKeyCalled)
    } catch {
      XCTFail("Unexpected error: \(error.localizedDescription)")
    }
  }

  func testWrongBiometrics() async throws {
    userSession.startSessionPassphraseCredentialTypeReturnValue = context
    context.evaluatePolicyLocalizedReasonReturnValue = true
    uniquePassphraseManager.getUniquePassphraseAuthMethodContextThrowableError = VaultError.secretRetrievalError(reason: "wrong biometrics")
    do {
      try await useCase()
      XCTFail("Should fail instead...")
    } catch VaultError.secretRetrievalError {
      XCTAssertTrue(context.evaluatePolicyLocalizedReasonCalled)
      XCTAssertTrue(uniquePassphraseManager.getUniquePassphraseAuthMethodContextCalled)
      XCTAssertFalse(userSession.startSessionPassphraseCredentialTypeCalled)

      XCTAssertFalse(dataStoreConfiguration.setEncryptionKeyCalled)
    } catch {
      XCTFail("Unexpected error: \(error.localizedDescription)")
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var uniquePassphraseManager: UniquePassphraseManagerProtocolSpy!
  private var userSession: SessionSpy!
  private var context: LAContextProtocolSpy!
  private var useCase: LoginBiometricUseCase!
  private var dataStoreConfiguration: DataStoreConfigurationManagerProtocolSpy!
  // swiftlint:enable all

}
