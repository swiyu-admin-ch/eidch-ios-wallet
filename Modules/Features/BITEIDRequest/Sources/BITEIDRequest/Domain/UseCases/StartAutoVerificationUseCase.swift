import Factory
import Spyable

// MARK: - StartAutoVerificationUseCaseProtocol

@Spyable
protocol StartAutoVerificationUseCaseProtocol {
  func execute(for caseId: String) async throws -> AutoVerificationResponse
}

// MARK: - StartAutoVerificationUseCase

struct StartAutoVerificationUseCase: StartAutoVerificationUseCaseProtocol {

  func execute(for caseId: String) async throws -> AutoVerificationResponse {
    try await eIDRequestRepository.startAutoVerification(caseId: caseId, autoVerificationType: .av1)
  }

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository
}
