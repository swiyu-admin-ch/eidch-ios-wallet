import BITCore
import BITCrypto
import Factory
import Foundation
import Spyable
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITVault

// MARK: - UniquePassphraseRepositoryTests

@Suite
@MainActor
struct UniquePassphraseRepositoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let contextSpy = LAContextProtocolSpy()
    let secretManagerSpy = SecretManagerProtocolSpy()
    let keyManagerSpy = KeyManagerProtocolSpy()
    let processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    Container.shared.secretManager.register { secretManagerSpy }
    Container.shared.keyManager.register { keyManagerSpy }
    Container.shared.processInfoService.register { processInfoServiceSpy }

    self.contextSpy = contextSpy
    self.secretManagerSpy = secretManagerSpy
    repository = UniquePassphraseRepository()
  }

  // MARK: Internal

  @Test
  func saveUniquePassphrase_appPin() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.appPin
    let mockAccessControl = try createAccessControl(accessControlFlags: AuthMethod.appPin.accessControlFlags)
    try repository.saveUniquePassphrase(mockData, forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    #expect(secretManagerSpy.setForKeyQueryCalled)
    #expect(mockData == secretManagerSpy.setForKeyQueryReceivedArguments?.value as? Data)
    #expect(AuthMethod.appPin.identifierKey == secretManagerSpy.setForKeyQueryReceivedArguments?.key)
    // swiftlint:disable force_cast
    #expect(mockAccessControl == secretManagerSpy.setForKeyQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl)
    // swiftlint:enable force_cast
  }

  @Test
  func saveUniquePassphrase_biometric() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.biometric
    let mockAccessControl = try createAccessControl(accessControlFlags: AuthMethod.biometric.accessControlFlags)
    try repository.saveUniquePassphrase(mockData, forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    #expect(secretManagerSpy.setForKeyQueryCalled)
    #expect(mockData == secretManagerSpy.setForKeyQueryReceivedArguments?.value as? Data)
    #expect(AuthMethod.biometric.identifierKey == secretManagerSpy.setForKeyQueryReceivedArguments?.key)
    // swiftlint:disable force_cast
    #expect(mockAccessControl == secretManagerSpy.setForKeyQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl)
    // swiftlint:enable force_cast
  }

  @Test
  func getUniquePassphrase_appPin() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.appPin
    secretManagerSpy.dataForKeyQueryReturnValue = mockData
    let data = try repository.getUniquePassphrase(forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    #expect(mockData == data)
    #expect(secretManagerSpy.dataForKeyQueryCalled)
    #expect(AuthMethod.appPin.identifierKey == secretManagerSpy.dataForKeyQueryReceivedArguments?.key)
  }

  @Test
  func getUniquePassphrase_biometric() throws {
    let mockData = Data()
    let appPinAuthMethod = AuthMethod.biometric
    secretManagerSpy.dataForKeyQueryReturnValue = mockData
    let data = try repository.getUniquePassphrase(forAuthMethod: appPinAuthMethod, inContext: contextSpy)
    #expect(mockData == data)
    #expect(secretManagerSpy.dataForKeyQueryCalled)
    #expect(AuthMethod.biometric.identifierKey == secretManagerSpy.dataForKeyQueryReceivedArguments?.key)
  }

  @Test
  func deleteBiometricUniquePassphrase() throws {
    try repository.deleteBiometricUniquePassphrase()

    #expect(secretManagerSpy.removeObjectForKeyQueryCalled)
    #expect(AuthMethod.biometric.identifierKey == secretManagerSpy.removeObjectForKeyQueryReceivedArguments?.key)
  }

  @Test
  func hasUniquePassphrase_appPin() {
    secretManagerSpy.existsKeyQueryReturnValue = true
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .appPin)
    #expect(hasSecret)
    #expect(secretManagerSpy.existsKeyQueryCalled)
    #expect(AuthMethod.appPin.identifierKey == secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  @Test
  func hasUniquePassphrase_biometric() {
    secretManagerSpy.existsKeyQueryReturnValue = true
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .biometric)
    #expect(hasSecret)
    #expect(secretManagerSpy.existsKeyQueryCalled)
    #expect(AuthMethod.biometric.identifierKey == secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  @Test
  func hasNotUniquePassphrase_appPin() {
    secretManagerSpy.existsKeyQueryReturnValue = false
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .appPin)
    #expect(!hasSecret)
    #expect(secretManagerSpy.existsKeyQueryCalled)
    #expect(AuthMethod.appPin.identifierKey == secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  @Test
  func hasNotUniquePassphrase_biometric() {
    secretManagerSpy.existsKeyQueryReturnValue = false
    let hasSecret = repository.hasUniquePassphraseSaved(forAuthMethod: .biometric)
    #expect(!hasSecret)
    #expect(secretManagerSpy.existsKeyQueryCalled)
    #expect(AuthMethod.biometric.identifierKey == secretManagerSpy.existsKeyQueryReceivedArguments?.key)
  }

  // MARK: Private

  private let vaultAlgorithm = VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM

  private let contextSpy: LAContextProtocolSpy
  private let secretManagerSpy: SecretManagerProtocolSpy
  private let repository: UniquePassphraseRepositoryProtocol

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
