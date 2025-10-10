import BITAVWrapper
import BITEIDRequestShared
import Foundation

struct RecordDocumentOutput {

  init(_ packageResult: AVBeamPackageResult) {
    files = packageResult.files.map { EIDRequestCaseFile($0, category: .documentRecording) }
  }

  let files: [EIDRequestCaseFile]
}
