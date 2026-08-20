import Factory
import Foundation
import Spyable

// MARK: - CancelRequestCaseUseCaseProtocol

@Spyable
protocol CancelRequestCaseUseCaseProtocol {
  func callAsFunction(for caseId: String) async throws
}

// MARK: - CancelRequestCaseUseCase

struct CancelRequestCaseUseCase: CancelRequestCaseUseCaseProtocol {

  func callAsFunction(for caseId: String) async throws {
    try await sidRepository.abortRequestCase(for: caseId)
  }

  @ObservationIgnored @Injected(\.sidRepository) private var sidRepository: SIDRepositoryProtocol
}
