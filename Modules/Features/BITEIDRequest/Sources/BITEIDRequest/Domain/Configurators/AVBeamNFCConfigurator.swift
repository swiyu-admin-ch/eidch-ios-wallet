import BITAVWrapper
import BITEIDRequestShared
import BITL10n
import Factory
import Foundation
import Spyable

// MARK: - AVBeamNFCConfiguratorProtocol

@Spyable
protocol AVBeamNFCConfiguratorProtocol {
  func configure(for caseId: String, authenticationToken: String) async throws -> AVBeamScanNfcConfig
}

// MARK: - AVBeamNFCConfigurator

struct AVBeamNFCConfigurator: AVBeamNFCConfiguratorProtocol {

  // MARK: Internal

  func configure(for caseId: String, authenticationToken: String) async throws -> AVBeamScanNfcConfig {
    let resultFiles = try await fetchDocumentScanResultFiles(for: caseId)
    let packageData = try await fetchPackageData(for: caseId, files: resultFiles)

    return AVBeamScanNfcConfig(
      packageData: packageData,
      url: avSocketUrl,
      authToken: authenticationToken,
      popupMessages: [
        "searching": L10n.tkEidRequestNfcScanScannerSearchingHint,
        "reading": L10n.tkEidRequestNfcScanScannerReadingHint,
        "done": L10n.tkEidRequestNfcScanScannerDoneHint,
      ],
      saveAdditionalFiles: true,
      saveNfcResult: true,
      processId: caseId)
  }

  // MARK: Private

  private static let scanResultXmlFileName = "mobile-result.xml"
  private static let scanResultJsonFileName = "mobile-result.json"

  @Injected(\.avSocketUrl) private var avSocketUrl
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol

  private func fetchDocumentScanResultFiles(for caseId: String) async throws -> [AVBeamFile] {
    let scanResultJsonFile = try await eIDRequestCaseRepository.getFile(forRequestCaseId: caseId, name: Self.scanResultJsonFileName, category: .documentScan)
    let scanResultXmlFile = try await eIDRequestCaseRepository.getFile(forRequestCaseId: caseId, name: Self.scanResultXmlFileName, category: .documentScan)

    let jsonFile = AVBeamFile(scanResultJsonFile)
    let xmlFile = AVBeamFile(scanResultXmlFile)

    return [jsonFile, xmlFile]
  }

  private func fetchPackageData(for caseId: String, files: [AVBeamFile]) async throws -> AVBeamPackageData {
    let extractedDataFile = try await eIDRequestCaseRepository.getFile(forRequestCaseId: caseId, name: ScanDocumentOutput.extractedDataFileName, category: .documentScan)
    let extractedData = try JSONDecoder().decode([Int: String].self, from: extractedDataFile.data)

    return AVBeamPackageData(extractedData: extractedData, files: files)
  }
}
