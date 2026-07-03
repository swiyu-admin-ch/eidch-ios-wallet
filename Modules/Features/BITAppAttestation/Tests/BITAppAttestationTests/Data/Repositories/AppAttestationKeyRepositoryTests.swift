// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// MARK: - AppAttestationKeyRepositoryTests

final class AppAttestationKeyRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    repository = AppAttestationKeyRepository()
    success()
  }

  // MARK: - createClientAttestationKey

  func testCreate_clientAttestation_success() throws {
    let key = try repository.create(for: .client, with: context)

    XCTAssertEqual(key, mockKeyPair)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, attestationKeyAlgorithm)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, clientAttestationKeychainIdentifier)

    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier, clientAttestationKeychainIdentifier)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, attestationKeyAlgorithm)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, attestationKeyVaultOptions)
  }

  func testCreate_keyAttestation_success() throws {
    let key = try repository.create(for: .key, with: context)

    XCTAssertEqual(key, mockKeyPair)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, attestationKeyAlgorithm)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, keyAttestationKeychainIdentifier)

    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier, keyAttestationKeychainIdentifier)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, attestationKeyAlgorithm)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, attestationKeyVaultOptions)
  }

  func testCreate_clientAttestation_callsCount() throws {
    let key = try repository.create(for: .client, with: context)

    XCTAssertEqual(key, mockKeyPair)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCallsCount, 1)
  }

  func testCreate_deleteKeyPairFails_throws() throws {
    keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.create(for: .client, with: context)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCreate_generateKeyPairFails_throws() throws {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.create(for: .client, with: context)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGet_success() throws {
    let keyPair = VaultKeyPair.Mock.ES256WithoutOptions
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReturnValue = keyPair

    let key = try repository.get(for: .client)

    XCTAssertEqual(key, keyPair)
    XCTAssertEqual(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testGet_failure() throws {
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.get(for: .client)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let clientAttestationKeychainIdentifier = AttestationType.client.keychainIdentifier
  private let keyAttestationKeychainIdentifier = AttestationType.key.keychainIdentifier
  private let attestationKeyAlgorithm = VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM
  private let attestationKeyVaultOptions = VaultOptions.secureEnclavePermanently

  private var repository: AppAttestationKeyRepository!

  private var context: LAContextProtocolSpy!
  private var keyManagerSpy: KeyManagerProtocolSpy!

  private func registerMocks() {
    context = LAContextProtocolSpy()
    keyManagerSpy = KeyManagerProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.attestationKeyAlgorithm.register { self.attestationKeyAlgorithm }
    Container.shared.attestationKeyVaultOptions.register { self.attestationKeyVaultOptions }
  }

  private func success() {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockKeyPair
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
