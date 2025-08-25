import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable all

final class CredentialKeyRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    keyManagerProtocolSpy = KeyManagerProtocolSpy()

    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()

    Container.shared.reset()
    Container.shared.keyManager.register { self.keyManagerProtocolSpy }
    Container.shared.userSession.register { self.userSession }

    repository = CredentialKeyRepository()

    success()
  }

  func testCreate_argumentsPassedToKeyManager_success() throws {
    let keyPair = try repository.create(algorithm: mockAlgorithm, isHardwareBound: true)
    XCTAssertEqual(mockKeyPair, keyPair)
    XCTAssertTrue(keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCalled)
    XCTAssertEqual(keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, try VaultAlgorithm(fromSignatureAlgorithm: mockAlgorithm))
    XCTAssertEqual(keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, vaultOptions)
    XCTAssertEqual((keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecUseAuthenticationContext as String] as? LAContextProtocolSpy)?.localizedReason, mockReason) // Compare reason cause cannot compare LAContextProtocol
    XCTAssertEqual(keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl, SecKeyTestsHelper.createAccessControl(accessControlFlags: .privateKeyUsage, protection: mockProtection))
  }

  func testCreate_hardwareBound_setsPrivateKeyUsageAccessControl() throws {
    _ = try repository.create(algorithm: mockAlgorithm, isHardwareBound: true)

    XCTAssertEqual(keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl, SecKeyTestsHelper.createAccessControl(accessControlFlags: .privateKeyUsage, protection: mockProtection))
  }

  func testCreate_notHardwareBound_setsUserPresenceAccessControl() throws {
    _ = try repository.create(algorithm: mockAlgorithm, isHardwareBound: false)

    XCTAssertEqual(keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl, SecKeyTestsHelper.createAccessControl(accessControlFlags: .userPresence, protection: mockProtection))
  }

  func testCreate_unknownAlgorithm_throwsError() throws {
    let mockAlgorithm = "unknown"

    XCTAssertThrowsError(try repository.create(algorithm: mockAlgorithm, isHardwareBound: false)) { error in
      XCTAssertEqual(error as? CredentialKeyRepository.CredentialKeyRepositoryError, .invalidAlgorithm)
      XCTAssertFalse(keyManagerProtocolSpy.getKeyPairWithIdentifierAlgorithmQueryCalled)
    }
  }

  // MARK: Private

  private let mockAlgorithm = "ES256"
  private let mockReason = "mockReason"
  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private var keyManagerProtocolSpy = KeyManagerProtocolSpy()
  private var repository = CredentialKeyRepository()
  private var userSession = SessionSpy()
  private var vaultOptions = VaultOptions.secureEnclavePermanently
  private var mockProtection = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

  private func success() {
    keyManagerProtocolSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockKeyPair
    userSession.context?.localizedReason = mockReason
  }

  // swiftlint:enable all

}
