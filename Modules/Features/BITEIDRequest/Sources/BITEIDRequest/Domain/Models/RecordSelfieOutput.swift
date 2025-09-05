import BITAVWrapper
import BITEIDRequestShared
import Foundation

public struct RecordSelfieOutput {

  public init(_ packageResult: AVBeamPackageResult) {
    files = packageResult.files.map { EIDRequestCaseFile($0, category: .documentRecording) }
  }

  public let files: [EIDRequestCaseFile]
}
