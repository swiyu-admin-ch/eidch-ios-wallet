import BITLocalAuthentication
import BITVault
import Factory
import Security
import Spyable

// MARK: - AppAttestationKeyRepositoryProtocol

@Spyable
public protocol AppAttestationKeyRepositoryProtocol {
  func get(for type: AttestationType) throws -> VaultKeyPair
  func create(for type: AttestationType, with context: LAContextProtocol) throws -> VaultKeyPair
}

// MARK: - AppAttestationKeyRepository

struct AppAttestationKeyRepository: AppAttestationKeyRepositoryProtocol {

  // MARK: Internal

  func get(for type: AttestationType) throws -> VaultKeyPair {
    try keyManager.getKeyPair(withIdentifier: type.keychainIdentifier, algorithm: attestationKeyAlgorithm)
  }

  func create(for type: AttestationType, with context: any LAContextProtocol) throws -> VaultKeyPair {
    try keyManager.deleteKeyPair(withIdentifier: type.keychainIdentifier, algorithm: attestationKeyAlgorithm)

    let query = try QueryBuilder()
      .setAccessControlFlags(attestationKeyVaultOptions.secAccessControl)
      .setProtection(protection)
      .setContext(context)
      .build()

    return try keyManager.generateKeyPair(
      withIdentifier: type.keychainIdentifier,
      algorithm: attestationKeyAlgorithm,
      options: attestationKeyVaultOptions,
      query: query)
  }

  // MARK: Private

  private let protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.attestationKeyAlgorithm) private var attestationKeyAlgorithm: VaultAlgorithm
  @Injected(\.attestationKeyVaultOptions) private var attestationKeyVaultOptions: VaultOptions
}
