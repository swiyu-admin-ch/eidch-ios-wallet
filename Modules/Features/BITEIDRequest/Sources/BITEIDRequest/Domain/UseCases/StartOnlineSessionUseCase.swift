import Factory
import Spyable

// MARK: - StartOnlineSessionUseCaseProtocol

@Spyable
protocol StartOnlineSessionUseCaseProtocol {
  func execute(for caseId: String) async throws
}

// MARK: - StartOnlineSessionUseCase

struct StartOnlineSessionUseCase: StartOnlineSessionUseCaseProtocol {
  func execute(for caseId: String) async throws {
    try await eIDRequestRepository.startOnlineSession(caseId: caseId)
  }

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
}
