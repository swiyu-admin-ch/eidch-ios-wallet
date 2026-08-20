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
  func callAsFunction(for credentialId: UUID) async throws -> CredentialIssuanceSummary
}

// MARK: - GetCredentialIssuanceSummaryUseCase

struct GetCredentialIssuanceSummaryUseCase: GetCredentialIssuanceSummaryUseCaseProtocol {

  func callAsFunction(for credentialId: UUID) async throws -> CredentialIssuanceSummary {
    do {
      return try await credentialRepository.getIssuanceSummary(id: credentialId)
    } catch CredentialRepositoryError.unsupportedCredential {
      throw GetCredentialIssuanceSummaryUseCaseError.unsupportedCredential
    }
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProtocol
}
