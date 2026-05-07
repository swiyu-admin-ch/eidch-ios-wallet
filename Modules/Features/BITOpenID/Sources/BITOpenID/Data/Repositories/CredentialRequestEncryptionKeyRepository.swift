import BITVault
import Factory
import Foundation
import Spyable

// MARK: - CredentialResponseEncryptionKeyRepositoryProtocol

@Spyable
protocol CredentialResponseEncryptionKeyRepositoryProtocol {
  func create(
    using responseEncryption: CredentialIssuerMetadata.CredentialResponseEncryption) throws
    -> VaultKeyPair
}

// MARK: - CredentialResponseEncryptionKeyRepository

struct CredentialResponseEncryptionKeyRepository: CredentialResponseEncryptionKeyRepositoryProtocol {

  // MARK: Internal

  func create(using responseEncryption: CredentialIssuerMetadata.CredentialResponseEncryption) throws -> VaultKeyPair {
    let algorithm = try VaultAlgorithm(responseEncryption)

    return try keyManager.generateKeyPair(
      withIdentifier: UUID().uuidString,
      algorithm: algorithm,
      options: [],
      query: nil)
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol

}
