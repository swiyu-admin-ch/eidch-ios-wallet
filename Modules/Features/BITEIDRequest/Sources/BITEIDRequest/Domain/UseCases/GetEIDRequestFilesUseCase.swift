import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
protocol GetEIDRequestCaseFilesUseCaseProtocol {
  func execute(caseId: String) async throws -> [EIDRequestCaseFile]
}


struct GetEIDRequestCaseFilesUseCase: GetEIDRequestCaseFilesUseCaseProtocol {
  func execute(caseId: String) async throws -> [EIDRequestCaseFile] {
    try await eIDRequestCaseRepository.getAllFiles(forRequestCaseId: caseId)
  }

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository
}
