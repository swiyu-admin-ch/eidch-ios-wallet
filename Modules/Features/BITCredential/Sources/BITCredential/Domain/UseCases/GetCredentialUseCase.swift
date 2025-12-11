import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - GetCredentialUseCaseProtocol

@Spyable
public protocol GetCredentialUseCaseProtocol {
  func callAsFunction(id: UUID) async throws -> CredentialProtocol
}

// MARK: - GetCredentialUseCase

struct GetCredentialUseCase: GetCredentialUseCaseProtocol {

  func callAsFunction(id: UUID) async throws -> CredentialProtocol {
    try await credentialRepository.get(id: id)
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository
}
