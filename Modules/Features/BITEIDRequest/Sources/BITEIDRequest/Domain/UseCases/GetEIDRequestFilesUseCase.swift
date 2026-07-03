import BITAVWrapper
import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
protocol GetEIDRequestCaseFilesUseCaseProtocol {
  func execute(caseId: String) async throws -> [EIDRequestCaseFile]
}


struct GetEIDRequestCaseFilesUseCase: GetEIDRequestCaseFilesUseCaseProtocol {

  // MARK: Internal

  func execute(caseId: String) async throws -> [EIDRequestCaseFile] {
    let files = try await eIDRequestCaseRepository.getAllFiles(forRequestCaseId: caseId)
    let metadataBinaryFile = try generateMetadataBinary(files: files, caseId: caseId)
    let allFiles = files + [metadataBinaryFile]
    return allFiles.filter { allowedFiles.contains($0.fileName) }
  }

  // MARK: Private

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository
  @Injected(\.sidAllowedFiles) private var allowedFiles

  private func generateMetadataBinary(files: [EIDRequestCaseFile], caseId: String) throws -> EIDRequestCaseFile {
    let metadataJsonFiles = files.filter { $0.mime == .json && $0.fileName.hasPrefix("metadata-") }
    let records = try metadataJsonFiles.map { try JSONDecoder().decode([MotionRecord].self, from: $0.data) }.flatMap { $0 }
    let header = MotionHeader(processId: 0, recordsCount: records.count)
    let motionMetadata = MotionMetadata(header: header, records: records)

    return EIDRequestCaseFile(fileName: "metadata.bin", mime: .bin, data: motionMetadata.asData(), category: .other)
  }
}
