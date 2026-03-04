// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Foundation
import XCTest
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// MARK: - CredentialResponseEncryptionKeyRepositoryTests

final class CredentialResponseEncryptionKeyRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()
    registerMocks()
    repository = CredentialResponseEncryptionKeyRepository()
    success()
  }

  // MARK: - create

  func testCreate_success() throws {
    let keyPair = try repository.create(using: responseEncryptionMock)

    XCTAssertEqual(keyPair, keyPairMock)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, VaultAlgorithm.ecdhP256)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, VaultOptions.none)
    XCTAssertNil(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query)
    XCTAssertNotNil(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCallsCount, 1)
  }

  func testCreate_generateKeyPairFails_throws() throws {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try repository.create(using: responseEncryptionMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCreate_unsupportedAlgorithm_throws() throws {
    let responseEncryptionMock = CredentialMetadata.CredentialResponseEncryption(
      supportedAlgorithmValues: [],
      supportedEncryptionAlgorithms: [.A128GCM],
      supportedZipValues: nil,
      encryptionRequired: false)

    XCTAssertThrowsError(try repository.create(using: responseEncryptionMock)) { error in
      XCTAssertEqual(error as? VaultAlgorithm.CredentialResponseEncryptionKeyError, .responseEncryptionAlgorithmError)
      XCTAssertFalse(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCalled)
    }
  }

  // MARK: Private

  private let keyPairMock = VaultKeyPair.Mock.ES256
  private let responseEncryptionMock = CredentialMetadata.CredentialResponseEncryption(
    supportedAlgorithmValues: [.ECDH_ES],
    supportedEncryptionAlgorithms: [.A128GCM],
    supportedZipValues: [.deflate],
    encryptionRequired: false)

  private var repository: CredentialResponseEncryptionKeyRepository!
  private var keyManagerSpy: KeyManagerProtocolSpy!

  private func registerMocks() {
    keyManagerSpy = KeyManagerProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerSpy }
  }

  private func success() {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = keyPairMock
  }

}
