import Factory
import Spyable


@Spyable
protocol SubmitEIDRequestUseCaseProtocol {
  func callAsFunction(caseId: String, authJwt: String) async throws
}


struct SubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {
  func callAsFunction(caseId: String, authJwt: String) async throws {
    try await eIDRequestRepository.submitRequest(caseId: caseId, authJwt: authJwt)
    try? await updateRequestCaseFileSubmission(caseId)
  }

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository

  private func updateRequestCaseFileSubmission(_ caseId: String) async throws {
    var requestCase = try await eIDRequestCaseRepository.get(id: caseId)
    requestCase.filesSubmitted = true
    try await eIDRequestCaseRepository.update(requestCase)
  }
}
