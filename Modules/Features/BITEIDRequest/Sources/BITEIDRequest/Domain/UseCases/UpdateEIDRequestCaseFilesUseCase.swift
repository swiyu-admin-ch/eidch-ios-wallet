import BITAVWrapper
import Factory
import Spyable


@Spyable
protocol UpdateEIDRequestCaseFilesUseCaseProtocol {
  func callAsFunction(for caseId: String, scanDocumentOutput: ScanDocumentOutput) async throws
}


struct UpdateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocol {

  func callAsFunction(for caseId: String, scanDocumentOutput: ScanDocumentOutput) async throws {
    try await eIDRequestCaseRepository.deleteAllFiles(forRequestCaseId: caseId)
    try await eIDRequestCaseRepository.save(files: scanDocumentOutput.files, forRequestCaseId: caseId)
  }

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
