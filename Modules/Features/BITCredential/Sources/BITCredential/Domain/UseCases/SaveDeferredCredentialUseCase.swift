import BITCredentialShared
import Factory
import Spyable

// MARK: - SaveDeferredCredentialUseCaseProtocol

@Spyable
public protocol SaveDeferredCredentialUseCaseProtocol {
  func execute(for deferredCredential: DeferredCredential) async throws
}

// MARK: - SaveDeferredCredentialUseCase

struct SaveDeferredCredentialUseCase: SaveDeferredCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for deferredCredential: DeferredCredential) async throws {
    try await credentialRepository.create(deferredCredential: deferredCredential)
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
}
