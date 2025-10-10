import BITAVWrapper
import BITEIDRequestShared
import Foundation

// MARK: - ScanDocumentOutput

public struct ScanDocumentOutput: Equatable {

  // MARK: Lifecycle

  init(_ packageResult: AVBeamPackageResult, identityType: IdentityType) throws {
    mrz = try MRZ(from: packageResult)
    files = packageResult.data.files.map { EIDRequestCaseFile($0, category: .documentScan) }
    self.identityType = identityType
  }

  init(mrz: MRZ, files: [EIDRequestCaseFile] = [], identityType: IdentityType) {
    self.mrz = mrz
    self.files = files
    self.identityType = identityType
  }

  // MARK: Internal

  let mrz: MRZ
  let files: [EIDRequestCaseFile]
  let identityType: IdentityType

}
