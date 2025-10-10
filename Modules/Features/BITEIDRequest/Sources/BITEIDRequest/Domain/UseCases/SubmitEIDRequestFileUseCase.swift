import BITEIDRequestShared
import BITNetworking
import Factory
import Foundation
import Spyable


@Spyable
protocol SubmitEIDRequestFileUseCaseProtocol {
  func execute(caseId: String, file: EIDRequestCaseFile, authJwt: String, _ progress: ProgressHandler?) async throws
}


struct SubmitEIDRequestFileUseCase: SubmitEIDRequestFileUseCaseProtocol {
  func execute(caseId: String, file: EIDRequestCaseFile, authJwt: String, _ progress: ProgressHandler?) async throws {
    try await eidRequestRepository.submitFile(file, caseId: caseId, authJwt: authJwt, progress)
  }

  @Injected(\.eIDRequestRepository) private var eidRequestRepository
}
