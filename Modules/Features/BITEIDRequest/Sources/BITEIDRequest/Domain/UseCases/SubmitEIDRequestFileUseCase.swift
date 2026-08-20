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
    try await avRepository.submitFile(file, caseId: caseId, authJwt: authJwt, progress)
  }

  @Injected(\.avRepository) private var avRepository: AVRepositoryProtocol
}
