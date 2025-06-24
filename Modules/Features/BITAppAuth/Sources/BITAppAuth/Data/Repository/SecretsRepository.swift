import BITCore
import BITCrypto
import BITLocalAuthentication
import BITVault
import Factory
import Foundation

// MARK: - SecretsError

enum SecretsError: Error {
  case dataConversionError
  case unavailableData
}

// MARK: - SecretsKey

private enum SecretsKey {
  static let authenticationServiceKey = "ch.admin.foitt.federal-wallet.authentication"

  static let saltAppPinIdentifierKey = "saltAppPinIdentifierKey"
  static let pepperAppPinIdentifierKey = "pepperAppPinIdentifierKey"
  static let pepperInitialVectorIdentifierKey = "pepperInitialVectorIdentifierKey"
  static let lockedWalletUptime = "lockedWalletUptime"
  static let clientAttestationIdentifierKey = "clientAttestationIdentifierKey"
  static let keyAttestationIdentifierKey = "keyAttestationIdentifierKey"
}

// MARK: - SecretConfiguration

fileprivate enum SecretConfiguration {
  static let protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
}

// MARK: - SecretsRepository

struct SecretsRepository {

  // MARK: Private

  @Injected(\.secretManager) private var secretManager: SecretManagerProtocol
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.processInfoService) private var processInfoService: ProcessInfoServiceProtocol
  @Injected(\.vaultOptions) private var vaultOptions: VaultOption
  @Injected(\.vaultAlgorithm) private var vaultAlgorithm: VaultAlgorithm

}

// MARK: LockWalletRepositoryProtocol

extension SecretsRepository: LockWalletRepositoryProtocol {
  func getLockedWalletTimeInterval() -> TimeInterval? {
    secretManager.double(forKey: SecretsKey.lockedWalletUptime)
  }

  func lockWallet() throws {
    try secretManager.set(processInfoService.systemUptime, forKey: SecretsKey.lockedWalletUptime)
  }

  func unlockWallet() throws {
    try secretManager.removeObject(forKey: SecretsKey.lockedWalletUptime)
  }
}

// MARK: UniquePassphraseRepositoryProtocol

extension SecretsRepository: UniquePassphraseRepositoryProtocol {

  func saveUniquePassphrase(_ data: Data, forAuthMethod authMethod: AuthMethod, inContext context: LAContextProtocol) throws {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .setAccessControlFlags(authMethod.accessControlFlags)
      .setProtection(SecretConfiguration.protection)
      .setContext(context)
      .build()

    try secretManager.set(data, forKey: authMethod.identifierKey, query: query)
  }

  func hasUniquePassphraseSaved(forAuthMethod authMethod: AuthMethod) -> Bool {
    do {
      let query = try QueryBuilder()
        .setService(SecretsKey.authenticationServiceKey)
        .build()

      return secretManager.exists(key: authMethod.identifierKey, query: query)
    } catch {
      return false
    }
  }

  func getUniquePassphrase(forAuthMethod authMethod: AuthMethod, inContext context: LAContextProtocol) throws -> Data {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .setContext(context)
      .build()

    guard let data = secretManager.data(forKey: authMethod.identifierKey, query: query) else {
      throw SecretsError.unavailableData
    }

    return data
  }

  func deleteBiometricUniquePassphrase() throws {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .build()

    try secretManager.removeObject(forKey: AuthMethod.biometric.identifierKey, query: query)
  }
}

// MARK: PepperRepositoryProtocol

extension SecretsRepository: PepperRepositoryProtocol {

  func createPepperKey() throws -> SecKey {
    try keyManager.deleteKeyPair(withIdentifier: SecretsKey.pepperAppPinIdentifierKey, algorithm: vaultAlgorithm)

    let query = try QueryBuilder()
      .setAccessControlFlags([.privateKeyUsage])
      .setProtection(SecretConfiguration.protection)
      .build()

    return try keyManager.generateKeyPair(
      withIdentifier: SecretsKey.pepperAppPinIdentifierKey,
      algorithm: vaultAlgorithm,
      options: vaultOptions,
      query: query)
  }

  func getPepperKey() throws -> SecKey {
    try keyManager.getPrivateKey(
      withIdentifier: SecretsKey.pepperAppPinIdentifierKey,
      algorithm: vaultAlgorithm)
  }

  func setPepperInitialVector(_ initialVector: Data) throws {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .setAccessControlFlags([])
      .setProtection(SecretConfiguration.protection)
      .build()

    try secretManager.set(initialVector, forKey: SecretsKey.pepperInitialVectorIdentifierKey, query: query)
  }

  func getPepperInitialVector() throws -> Data {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .build()

    guard let data = secretManager.data(forKey: SecretsKey.pepperInitialVectorIdentifierKey, query: query) else {
      throw SecretsError.unavailableData
    }

    return data
  }
}

// MARK: SaltRepositoryProtocol

extension SecretsRepository: SaltRepositoryProtocol {
  func setPinSalt(_ salt: Data) throws {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .setAccessControlFlags([])
      .setProtection(SecretConfiguration.protection)
      .build()

    try secretManager.set(salt, forKey: SecretsKey.saltAppPinIdentifierKey, query: query)
  }

  func getPinSalt() throws -> Data {
    let query = try QueryBuilder()
      .setService(SecretsKey.authenticationServiceKey)
      .build()

    guard let data = secretManager.data(forKey: SecretsKey.saltAppPinIdentifierKey, query: query) else {
      throw SecretsError.unavailableData
    }

    return data
  }
}

// MARK: AppAttestationKeyRepositoryProtocol

extension SecretsRepository: AppAttestationKeyRepositoryProtocol {
  func getAttestionKey(for attestKey: AppAttestationKey) throws -> SecKey {
    let keyIdentifier = switch attestKey {
    case .clientAttestation: SecretsKey.clientAttestationIdentifierKey
    case .keyAttestation: SecretsKey.keyAttestationIdentifierKey
    }

    return try keyManager.getPrivateKey(withIdentifier: keyIdentifier, algorithm: vaultAlgorithm, query: nil)
  }

  func createAttestationKey(for attestKey: AppAttestationKey, with context: any LAContextProtocol) throws -> SecKey {
    let keyIdentifier = switch attestKey {
    case .clientAttestation: SecretsKey.clientAttestationIdentifierKey
    case .keyAttestation: SecretsKey.keyAttestationIdentifierKey
    }

    try keyManager.deleteKeyPair(withIdentifier: keyIdentifier, algorithm: vaultAlgorithm)

    let query = try QueryBuilder()
      .setAccessControlFlags([.privateKeyUsage])
      .setProtection(SecretConfiguration.protection)
      .setContext(context)
      .build()

    return try keyManager.generateKeyPair(withIdentifier: keyIdentifier, algorithm: vaultAlgorithm, options: vaultOptions, query: query)
  }
}
