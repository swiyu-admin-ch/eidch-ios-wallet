#if DEBUG
import Foundation

extension EIDRequestContext {
  struct Mock {
    static let documentRecordingSample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: false,
        isScanDocumentRequired: false,
        isDocumentVideoRecordingRequired: true))

    static let scanDocumentSample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: false,
        isScanDocumentRequired: true,
        isDocumentVideoRecordingRequired: false))

    static let nfcSample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: true,
        isScanDocumentRequired: false,
        isDocumentVideoRecordingRequired: false))

    static let sample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: false,
        isScanDocumentRequired: false,
        isDocumentVideoRecordingRequired: false))
  }
}
#endif
