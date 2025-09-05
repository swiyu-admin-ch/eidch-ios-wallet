import BITAVWrapper
import BITEIDRequestShared
import Foundation

// MARK: - ScanDocumentOutput

public struct ScanDocumentOutput: Equatable {

  // MARK: Lifecycle

  public init(_ packageResult: AVBeamPackageResult, identityType: IdentityType) throws {
    mrz = try MRZ(from: packageResult)
    files = packageResult.data.files.map { EIDRequestCaseFile($0, category: .documentScan) }
    self.identityType = identityType
  }

  public init(mrz: MRZ, files: [EIDRequestCaseFile] = [], identityType: IdentityType) {
    self.mrz = mrz
    self.files = files
    self.identityType = identityType
  }

  // MARK: Public

  public let mrz: MRZ
  public let files: [EIDRequestCaseFile]
  public let identityType: IdentityType

}
