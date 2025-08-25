// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// MARK: - AppPepperKeyRepositoryTests

final class AppPepperKeyRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    repository = AppPepperKeyRepository()
    success()
  }

  // MARK: - createClientAttestationKey

  func testCreate_success() throws {
    _ = try repository.create()

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, pepperKeyAlgorithm)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, AppPepperKeyRepository.pepperAppPinIdentifierKey)

    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier, AppPepperKeyRepository.pepperAppPinIdentifierKey)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, pepperKeyAlgorithm)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, pepperKeyVaultOptions)
  }

  func testCreate_callsCount() throws {
    _ = try repository.create()

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCallsCount, 1)
  }

  func testCreate_deleteKeyPairFails_throws() throws {
    keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.create()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCreate_generateKeyPairFails_throws() throws {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.create()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGet_success() throws {
    _ = try repository.get()

    XCTAssertEqual(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testGet_failure() throws {
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.get()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private let pepperKeyAlgorithm = VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM
  private let pepperKeyVaultOptions = VaultOptions.secureEnclavePermanently

  private var repository: AppPepperKeyRepository!

  private var keyManagerSpy: KeyManagerProtocolSpy!

  private func registerMocks() {
    keyManagerSpy = KeyManagerProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.pepperKeyAlgorithm.register { self.pepperKeyAlgorithm }
    Container.shared.pepperKeyVaultOptions.register { self.pepperKeyVaultOptions }
  }

  private func success() {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockKeyPair
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
