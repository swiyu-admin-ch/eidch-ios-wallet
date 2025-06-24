// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// MARK: - AppAttestationKeyRepositoryTests

final class AppAttestationKeyRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    repository = SecretsRepository()
    createSuccessState()
  }

  // MARK: - createClientAttestationKey

  func testCreateAttestationKey_parameters_success() throws {
    _ = try repository.createAttestationKey(for: .clientAttestation, with: context)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, vaultAlgorithm)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, clientAttestationIdentifierKey)

    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier, clientAttestationIdentifierKey)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, vaultAlgorithm)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, [.secureEnclavePermanently])
  }

  func testCreateAttestationKey_count_success() throws {
    _ = try repository.createAttestationKey(for: .clientAttestation, with: context)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCallsCount, 1)
  }

  func testCreateAttestationKey_deleteKeyPairFails_throws() throws {
    keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.createAttestationKey(for: .clientAttestation, with: context)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCreateClientAttestationKey_generateKeyPairFails_throws() throws {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.createAttestationKey(for: .clientAttestation, with: context)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: - getClientAttestationKey

  func testGetAttestationKey_success() throws {
    _ = try repository.getAttestionKey(for: .clientAttestation)

    XCTAssertEqual(keyManagerSpy.getPrivateKeyWithIdentifierAlgorithmQueryCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.getPrivateKeyWithIdentifierAlgorithmQueryReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testGetAttestationKey_failure() throws {
    keyManagerSpy.getPrivateKeyWithIdentifierAlgorithmQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.getAttestionKey(for: .clientAttestation)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockSecKey: SecKey = SecKeyTestsHelper.createPrivateKey()
  private let clientAttestationIdentifierKey = "clientAttestationIdentifierKey"
  private let vaultAlgorithm = VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM

  private var context: LAContextProtocolSpy!
  private var keyManagerSpy: KeyManagerProtocolSpy!
  private var repository: AppAttestationKeyRepositoryProtocol!
  private var secretManagerSpy: SecretManagerProtocolSpy!
  private var processInfoServiceSpy: ProcessInfoServiceProtocolSpy!

  private func registerMocks() {
    context = LAContextProtocolSpy()
    secretManagerSpy = SecretManagerProtocolSpy()
    keyManagerSpy = KeyManagerProtocolSpy()
    processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    Container.shared.secretManager.register { self.secretManagerSpy }
    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.processInfoService.register { self.processInfoServiceSpy }
  }

  private func createSuccessState() {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockSecKey
    keyManagerSpy.getPublicKeyWithIdentifierAlgorithmQueryReturnValue = mockSecKey
    keyManagerSpy.getPrivateKeyWithIdentifierAlgorithmQueryReturnValue = mockSecKey
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
