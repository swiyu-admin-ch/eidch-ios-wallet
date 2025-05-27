import BITCore
import BITCrypto
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITVault

final class UniquePassphraseRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    repository = SecretsRepository()
  }

  func testSaveUniquePassphrase_appPin() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.appPin
    let mockAccessControl = try createAccessControl(accessControlFlags: AuthMethod.appPin.accessControlFlags)
    try repository.saveUniquePassphrase(mockData, forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    XCTAssertTrue(secretManagerSpy.setForKeyQueryCalled)
    XCTAssertEqual(mockData, secretManagerSpy.setForKeyQueryReceivedArguments?.value as? Data)
    XCTAssertEqual(AuthMethod.appPin.identifierKey, secretManagerSpy.setForKeyQueryReceivedArguments?.key)
    // swiftlint:disable force_cast
    XCTAssertEqual(mockAccessControl, secretManagerSpy.setForKeyQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl)
    // swiftlint:enable force_cast
  }

  func testSaveUniquePassphrase_biometric() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.biometric
    let mockAccessControl = try createAccessControl(accessControlFlags: AuthMethod.biometric.accessControlFlags)
    try repository.saveUniquePassphrase(mockData, forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    XCTAssertTrue(secretManagerSpy.setForKeyQueryCalled)
    XCTAssertEqual(mockData, secretManagerSpy.setForKeyQueryReceivedArguments?.value as? Data)
    XCTAssertEqual(AuthMethod.biometric.identifierKey, secretManagerSpy.setForKeyQueryReceivedArguments?.key)
    // swiftlint:disable force_cast
    XCTAssertEqual(mockAccessControl, secretManagerSpy.setForKeyQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl)
    // swiftlint:enable force_cast
  }

  func testGetUniquePassphrase_appPin() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.appPin
    secretManagerSpy.dataForKeyQueryReturnValue = mockData
    let data = try repository.getUniquePassphrase(forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    XCTAssertEqual(mockData, data)
    XCTAssertTrue(secretManagerSpy.dataForKeyQueryCalled)
    XCTAssertEqual(AuthMethod.appPin.identifierKey, secretManagerSpy.dataForKeyQueryReceivedArguments?.key)
  }

  func testGetUniquePassphrase_biometric() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.biometric
    secretManagerSpy.dataForKeyQueryReturnValue = mockData
    let data = try repository.getUniquePassphrase(forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    XCTAssertEqual(mockData, data)
    XCTAssertTrue(secretManagerSpy.dataForKeyQueryCalled)
    XCTAssertEqual(AuthMethod.biometric.identifierKey, secretManagerSpy.dataForKeyQueryReceivedArguments?.key)
  }

  func testDeleteBiometricUniquePassphrase() throws {
    try repository.deleteBiometricUniquePassphrase()

    XCTAssertTrue(secretManagerSpy.removeObjectForKeyQueryCalled)
    XCTAssertEqual(AuthMethod.biometric.identifierKey, secretManagerSpy.removeObjectForKeyQueryReceivedArguments?.key)
  }

  func testHasUniquePassphrase_appPin() throws {
    secretManagerSpy.existsKeyQueryReturnValue = true
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .appPin)
    XCTAssertTrue(hasSecret)
    XCTAssertTrue(secretManagerSpy.existsKeyQueryCalled)
    XCTAssertEqual(AuthMethod.appPin.identifierKey, secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  func testHasUniquePassphrase_biometric() throws {
    secretManagerSpy.existsKeyQueryReturnValue = true
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .biometric)
    XCTAssertTrue(hasSecret)
    XCTAssertTrue(secretManagerSpy.existsKeyQueryCalled)
    XCTAssertEqual(AuthMethod.biometric.identifierKey, secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  func testHasNotUniquePassphrase_appPin() throws {
    secretManagerSpy.existsKeyQueryReturnValue = false
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .appPin)
    XCTAssertFalse(hasSecret)
    XCTAssertTrue(secretManagerSpy.existsKeyQueryCalled)
    XCTAssertEqual(AuthMethod.appPin.identifierKey, secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  func testHasNotUniquePassphrase_biometric() throws {
    secretManagerSpy.existsKeyQueryReturnValue = false
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .biometric)
    XCTAssertFalse(hasSecret)
    XCTAssertTrue(secretManagerSpy.existsKeyQueryCalled)
    XCTAssertEqual(AuthMethod.biometric.identifierKey, secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  // MARK: Private

  private let vaultAlgorithm = VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM

  // swiftlint:disable all
  private var contextSpy: LAContextProtocolSpy!
  private var secretManagerSpy: SecretManagerProtocolSpy!
  private var keyManagerSpy: KeyManagerProtocolSpy!
  private var processInfoServiceSpy: ProcessInfoServiceProtocolSpy!
  private var repository: UniquePassphraseRepositoryProtocol!

  // swiftlint:enable all

  private func registerMocks() {
    contextSpy = LAContextProtocolSpy()
    secretManagerSpy = SecretManagerProtocolSpy()
    keyManagerSpy = KeyManagerProtocolSpy()
    processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    Container.shared.secretManager.register { self.secretManagerSpy }
    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.processInfoService.register { self.processInfoServiceSpy }
  }

  private func createAccessControl(
    accessControlFlags: SecAccessControlCreateFlags = [.privateKeyUsage, .applicationPassword],
    protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly) throws
    -> SecAccessControl
  {
    var accessControlError: Unmanaged<CFError>?

    guard let accessControl = SecAccessControlCreateWithFlags( kCFAllocatorDefault, protection, accessControlFlags, &accessControlError) else {
      if let error = accessControlError?.takeRetainedValue() {
        throw VaultError.keyGenerationError(reason: "Access control creation failed with error: \(error)")
      }
      throw VaultError.keyGenerationError(reason: "Unknown error during access control creation.")
    }
    return accessControl
  }

}
