#if DEBUG
import Foundation

extension EIDRequestContext {
  struct Mock {
    nonisolated(unsafe) static let documentRecordingSample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: false,
        isScanDocumentRequired: false,
        isDocumentVideoRecordingRequired: true))

    nonisolated(unsafe) static let scanDocumentSample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: false,
        isScanDocumentRequired: true,
        isDocumentVideoRecordingRequired: false))

    nonisolated(unsafe) static let nfcSample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: true,
        isScanDocumentRequired: false,
        isDocumentVideoRecordingRequired: false))

    nonisolated(unsafe) static let sample = EIDRequestContext(
      caseId: "caseId",
      autoVerificationResponse: AutoVerificationResponse(
        jwt: "jwt",
        isNFCRequired: false,
        isScanDocumentRequired: false,
        isDocumentVideoRecordingRequired: false))
  }
}
#endif
