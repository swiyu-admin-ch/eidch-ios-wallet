import BITAVWrapper
import BITEIDRequestShared
import Foundation

// MARK: - ScanDocumentOutput

public struct ScanDocumentOutput: Equatable, Hashable {

  // MARK: Lifecycle

  init(_ packageResult: AVBeamPackageResult, identityType: IdentityType) throws {
    mrz = try MRZ(from: packageResult)
    files = packageResult.files.map { EIDRequestCaseFile($0, category: .documentScan) }

    // Add extracted data as a file, for NFC scan
    let data = try JSONEncoder().encode(packageResult.data.extractedData)
    let extractedDataFile = EIDRequestCaseFile(fileName: Self.extractedDataFileName, mime: .json, data: data, category: .documentScan)

    files.append(extractedDataFile)

    self.identityType = identityType
  }

  init(mrz: MRZ, files: [EIDRequestCaseFile] = [], identityType: IdentityType) {
    self.mrz = mrz
    self.files = files
    self.identityType = identityType
  }

  // MARK: Public

  public let mrz: MRZ
  public let identityType: IdentityType

  public func hash(into hasher: inout Hasher) {
    hasher.combine(mrz)
    hasher.combine(files)
    hasher.combine(identityType)
  }

  // MARK: Internal

  struct ExtractedData: Codable {
    struct Step: Codable {
      struct Summary: Codable {
        let documentNumber: String
      }

      let summary: Summary
    }

    let steps: [Step]
  }

  static let extractedDataFileName = "extractedData.json"

  private(set) var files: [EIDRequestCaseFile]

}
