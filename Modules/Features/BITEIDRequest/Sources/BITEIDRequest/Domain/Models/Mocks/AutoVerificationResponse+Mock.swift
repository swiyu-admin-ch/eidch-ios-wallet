#if DEBUG
import Foundation
@testable import BITTestingCore

extension AutoVerificationResponse: Mockable {
  struct Mock {
    static let nfcSample = AutoVerificationResponse(jwt: "jwt", isNFCRequired: true, isScanDocumentRequired: false, isDocumentVideoRecordingRequired: false)
    static let scanDocumentSample = AutoVerificationResponse(jwt: "jwt", isNFCRequired: false, isScanDocumentRequired: true, isDocumentVideoRecordingRequired: true)
    static let recordDocumentSample = AutoVerificationResponse(jwt: "jwt", isNFCRequired: false, isScanDocumentRequired: false, isDocumentVideoRecordingRequired: true)
    static let sampleData: Data = Mocker.getData(fromFile: "auto-verification-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
