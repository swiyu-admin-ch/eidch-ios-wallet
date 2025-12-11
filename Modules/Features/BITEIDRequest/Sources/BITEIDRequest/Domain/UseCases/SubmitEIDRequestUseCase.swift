import Factory
import Spyable


@Spyable
protocol SubmitEIDRequestUseCaseProtocol {
  func callAsFunction(caseId: String, authJwt: String) async throws
}


struct SubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {
  func callAsFunction(caseId: String, authJwt: String) async throws {
    try await repository.submitRequest(caseId: caseId, authJwt: authJwt)
  }

  @Injected(\.eIDRequestRepository) private var repository
}
