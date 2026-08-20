import Factory
import Foundation
import Spyable

// MARK: - CompareScanDocumentOutputUseCaseProtocol

@Spyable
protocol CompareScanDocumentOutputUseCaseProtocol {
  func callAsFunction(for caseId: String, with output: ScanDocumentOutput) async -> Bool
}

// MARK: - CompareScanDocumentOutputUseCase

struct CompareScanDocumentOutputUseCase: CompareScanDocumentOutputUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(for caseId: String, with output: ScanDocumentOutput) async -> Bool {
    do {
      let previousScanResultFile = try await eIDRequestCaseRepository.getFile(forRequestCaseId: caseId, name: Self.filename, category: .documentScan)

      guard
        let previousScanExtractedData = try? JSONDecoder().decode(ScanDocumentOutput.ExtractedData.self, from: previousScanResultFile.data),
        let previousScanDocumentNumber = previousScanExtractedData.steps.first?.summary.documentNumber,
        let currentScanResultFile = output.files.first(where: { $0.category == .documentScan && $0.fileName == Self.filename }),
        let currentScanExtractedData = try? JSONDecoder().decode(ScanDocumentOutput.ExtractedData.self, from: currentScanResultFile.data),
        let currentScanDocumentNumber = currentScanExtractedData.steps.first?.summary.documentNumber
      else {
        return false
      }

      return previousScanDocumentNumber == currentScanDocumentNumber
    } catch {
      return false
    }
  }

  // MARK: Private

  private static let filename = "result.json"

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
