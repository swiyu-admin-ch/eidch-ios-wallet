import BITCredentialShared
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - DeleteCredentialUseCaseProtocol

@Spyable
public protocol DeleteCredentialUseCaseProtocol {
  func execute(_ credential: VerifiableCredential) async throws
}

// MARK: - DeleteCredentialError

enum DeleteCredentialError: Error {
  case invalidAlgorithm
}

// MARK: - DeleteCredentialUseCase

struct DeleteCredentialUseCase: DeleteCredentialUseCaseProtocol {

  func execute(_ credential: VerifiableCredential) async throws {
    if let keyAlgorithm = credential.keyBinding?.algorithm, let keyId = credential.keyBinding?.id, let algorithm = VaultAlgorithm(rawValue: keyAlgorithm) {
      try? keyManager.deleteKeyPair(withIdentifier: keyId.uuidString, algorithm: algorithm)
    }

    try await verifiableCredentialRepository.delete(credential.id)
  }

  // MARK: Private

  @Injected(\.verifiableCredentialRepository) private var verifiableCredentialRepository
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol

}
