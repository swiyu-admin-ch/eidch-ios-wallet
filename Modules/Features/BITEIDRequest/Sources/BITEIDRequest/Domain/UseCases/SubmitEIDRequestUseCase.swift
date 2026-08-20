import BITEIDRequestShared
import Factory
import Spyable


@Spyable
protocol SubmitEIDRequestUseCaseProtocol {
  func callAsFunction(caseId: String, authJwt: String, files: [EIDRequestCaseFile]) async throws
}


struct SubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {

  func callAsFunction(caseId: String, authJwt: String, files: [EIDRequestCaseFile]) async throws {
    try await avRepository.submitRequest(caseId: caseId, authJwt: authJwt, files: files)
    try? await updateRequestCaseFileSubmission(caseId)
  }

  @Injected(\.avRepository) private var avRepository
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository

  private func updateRequestCaseFileSubmission(_ caseId: String) async throws {
    var requestCase = try await eIDRequestCaseRepository.get(id: caseId)
    requestCase.filesSubmitted = true
    try await eIDRequestCaseRepository.update(requestCase)
  }
}
