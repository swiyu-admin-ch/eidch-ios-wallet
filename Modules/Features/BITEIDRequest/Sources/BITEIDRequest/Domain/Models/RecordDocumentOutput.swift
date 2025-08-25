import BITAVWrapper
import Foundation

public struct RecordDocumentOutput {

  public init(_ packageResult: AVBeamPackageResult) {
    files = packageResult.files.map { EIDRequestCaseFile($0, category: .documentRecording) }
  }

  public let files: [EIDRequestCaseFile]
}
