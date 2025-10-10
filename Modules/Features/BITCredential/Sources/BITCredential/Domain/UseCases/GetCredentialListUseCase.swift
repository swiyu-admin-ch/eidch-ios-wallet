import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - GetCredentialListUseCaseProtocol

@Spyable
public protocol GetCredentialListUseCaseProtocol {
  func execute() async throws -> [VerifiableCredential]
}

// MARK: - GetCredentialListUseCase

struct GetCredentialListUseCase: GetCredentialListUseCaseProtocol {

  func execute() async throws -> [VerifiableCredential] {
    try await verifiableCredentialRepository.getAll()
  }

  // MARK: Private

  @Injected(\.verifiableCredentialRepository) private var verifiableCredentialRepository
}
