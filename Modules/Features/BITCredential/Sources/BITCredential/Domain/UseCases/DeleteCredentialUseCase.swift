import BITCredentialShared
import BITVault
import Factory
import Foundation

// MARK: - DeleteCredentialError

enum DeleteCredentialError: Error {
  case invalidAlgorithm
}

// MARK: - DeleteCredentialUseCase

public struct DeleteCredentialUseCase: DeleteCredentialUseCaseProtocol {

  // MARK: Public

  public func execute(_ credential: Credential) async throws {
    if let keyAlgorithm = credential.keyBinding?.algorithm, let keyId = credential.keyBinding?.id, let algorithm = VaultAlgorithm(rawValue: keyAlgorithm) {
      try? keyManager.deleteKeyPair(withIdentifier: keyId.uuidString, algorithm: algorithm)
    }

    try await databaseRepository.delete(credential.id)
  }

  // MARK: Private

  @Injected(\.databaseCredentialRepository) private var databaseRepository: CredentialRepositoryProtocol
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol

}
