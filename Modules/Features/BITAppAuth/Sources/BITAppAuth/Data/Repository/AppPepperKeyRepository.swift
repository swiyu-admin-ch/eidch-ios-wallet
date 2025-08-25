import BITVault
import Factory
import Security
import Spyable

// MARK: - AppPepperKeyRepositoryProtocol

@Spyable
protocol AppPepperKeyRepositoryProtocol {
  func create() throws -> VaultKeyPair
  func get() throws -> VaultKeyPair
}

// MARK: - AppPepperKeyRepository

struct AppPepperKeyRepository: AppPepperKeyRepositoryProtocol {

  // MARK: Internal

  static let pepperAppPinIdentifierKey = "pepperAppPinIdentifierKey"

  func get() throws -> VaultKeyPair {
    try keyManager.getKeyPair(withIdentifier: Self.pepperAppPinIdentifierKey, algorithm: pepperKeyAlgorithm, query: nil)
  }

  func create() throws -> VaultKeyPair {
    try keyManager.deleteKeyPair(withIdentifier: Self.pepperAppPinIdentifierKey, algorithm: pepperKeyAlgorithm)

    let query = try QueryBuilder()
      .setAccessControlFlags(pepperKeyVaultOptions.secAccessControl)
      .setProtection(protection)
      .build()

    return try keyManager.generateKeyPair(
      withIdentifier: Self.pepperAppPinIdentifierKey,
      algorithm: pepperKeyAlgorithm,
      options: pepperKeyVaultOptions,
      query: query)
  }

  // MARK: Private

  private let protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.pepperKeyAlgorithm) private var pepperKeyAlgorithm: VaultAlgorithm
  @Injected(\.pepperKeyVaultOptions) private var pepperKeyVaultOptions: VaultOptions
}
