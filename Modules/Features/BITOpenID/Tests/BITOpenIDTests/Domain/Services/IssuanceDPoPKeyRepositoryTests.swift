import Factory
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable all

final class IssuanceDPoPKeyRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    keyManagerSpy = KeyManagerProtocolSpy()
    userSession = SessionSpy()
    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.userSession.register { self.userSession }

    repository = IssuanceDPoPKeyRepository()

    success()
  }

  func testCreate_hardwareBound_success() throws {
    let keyPair = try repository.create(isHardwareBound: true)

    XCTAssertEqual(keyPair, mockKeyPair)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, .secureEnclavePermanently)
    XCTAssertEqual((keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecUseAuthenticationContext as String] as? LAContextProtocolSpy)?.localizedReason, mockReason)
    XCTAssertEqual(
      keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl,
      SecKeyTestsHelper.createAccessControl(
        accessControlFlags: [.privateKeyUsage],
        protection: kSecAttrAccessibleWhenUnlockedThisDeviceOnly))
    XCTAssertNotNil(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier)
  }

  func testCreate_softwareBound_success() throws {
    let keyPair = try repository.create(isHardwareBound: false)

    XCTAssertEqual(keyPair, mockKeyPair)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
    XCTAssertEqual(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options, .savePermanently)
    XCTAssertEqual((keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecUseAuthenticationContext as String] as? LAContextProtocolSpy)?.localizedReason, mockReason)
    XCTAssertEqual(
      keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl,
      SecKeyTestsHelper.createAccessControl(
        accessControlFlags: [],
        protection: kSecAttrAccessibleWhenUnlockedThisDeviceOnly))
  }

  func testCreate_userNotLoggedIn_throws() throws {
    userSession.isLoggedIn = false

    XCTAssertThrowsError(try repository.create(isHardwareBound: true)) { error in
      XCTAssertEqual(error as? UserSessionError, .notLoggedIn)
      XCTAssertEqual(self.userSession.endSessionCallsCount, 1)
      XCTAssertEqual(self.keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCallsCount, 0)
    }
  }

  func testDelete_success() throws {
    try repository.delete(mockKeyPair)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, mockKeyPair.identifier)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, mockKeyPair.algorithm)
  }

  // MARK: Private

  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockReason = "mockReason"

  private var repository: IssuanceDPoPKeyRepository!
  private var keyManagerSpy: KeyManagerProtocolSpy!
  private var userSession: SessionSpy!

  private func success() {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockKeyPair
    userSession.context?.localizedReason = mockReason
  }
}

// swiftlint:enable all
