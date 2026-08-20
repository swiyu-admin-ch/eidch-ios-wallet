import Factory
import Foundation
import Spyable

// MARK: - ResetRequestCasePairingUseCaseProtocol

@Spyable
protocol ResetRequestCasePairingUseCaseProtocol {
  func callAsFunction(for caseId: String) async throws
}

// MARK: - ResetRequestCasePairingUseCase

struct ResetRequestCasePairingUseCase: ResetRequestCasePairingUseCaseProtocol {

  func callAsFunction(for caseId: String) async throws {
    try await eIDRequestCaseRepository.deletePairings(for: caseId)
  }

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
