import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - GetCredentialIssuanceSummaryUseCaseError

enum GetCredentialIssuanceSummaryUseCaseError: Error {
  case unsupportedCredential
}

// MARK: - GetCredentialIssuanceSummaryUseCaseProtocol

@Spyable
protocol GetCredentialIssuanceSummaryUseCaseProtocol {
  func execute(for credentialId: UUID) async throws -> CredentialIssuanceSummary
}

// MARK: - GetCredentialIssuanceSummaryUseCase

struct GetCredentialIssuanceSummaryUseCase: GetCredentialIssuanceSummaryUseCaseProtocol {

  func execute(for credentialId: UUID) async throws -> CredentialIssuanceSummary {
    do {
      return try await credentialRepository.getIssuanceSummary(id: credentialId)
    } catch CredentialRepositoryError.unsupportedCredential {
      throw GetCredentialIssuanceSummaryUseCaseError.unsupportedCredential
    }
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
}
