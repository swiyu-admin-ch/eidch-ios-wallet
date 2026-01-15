import BITCredentialShared
import Factory
import Spyable

// MARK: - AcceptCredentialUseCaseProtocol

@Spyable
public protocol AcceptCredentialUseCaseProtocol {
  @discardableResult
  func callAsFunction(_ credential: VerifiableCredential) async throws -> VerifiableCredential
}

// MARK: - AcceptCredentialUseCase

struct AcceptCredentialUseCase: AcceptCredentialUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    var credentialCopy = credential
    credentialCopy.progressionState = .accepted

    return try await credentialRepository.update(verifiableCredential: credentialCopy)
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
}
