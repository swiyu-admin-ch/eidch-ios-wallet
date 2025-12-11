import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - GetCredentialListUseCaseProtocol

@Spyable
public protocol GetCredentialListUseCaseProtocol {
  func execute() async throws -> [CredentialProtocol]
}

// MARK: - GetCredentialListUseCase

struct GetCredentialListUseCase: GetCredentialListUseCaseProtocol {

  func execute() async throws -> [CredentialProtocol] {
    try await credentialRepository.getAll()
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository
}
