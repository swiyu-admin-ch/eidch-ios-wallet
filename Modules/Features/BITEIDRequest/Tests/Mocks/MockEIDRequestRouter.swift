import BITNavigation
import Foundation
@testable import BITEIDRequest
@testable import BITPresentation


final class MockEIDRequestRouter: EIDRequestRouterRoutes {

  var context = EIDRequestContext()

  /// ClosableRoutes & ExternalRoutes
  var closeCalled = false
  var closeOnCompleteCalled = false
  var popCalled = false
  var popCountCalled = false
  var popToRootCalled = false
  var dismissCalled = false
  var externalLinkCalled = false
  var settingsCalled = false

  var eidRequestCalled = false
  var autoVerificationArgument: String?
  var optainConsentArgument: String?

  var dataPrivacyCalled = false
  var attestationCalled = false
  var legalRepresentantCalled = false
  var documentSelectionCalled = false
  var cameraPermissionCalled = false
  var scanDocumentCalled = false
  var mrzMockDataCalled = false
  var scanDocumentSubmitArgument: ScanDocumentOutput?
  var legalRepresentantConsentArgument: String?
  var legalRepresentantQRCodeArgument: String?
  var legalRepresentantVerificationArgument: String?
  var legalRepresentantEIDRequestCalled = false
  var legalRepresentantConsentStateArgument: RequestCaseViewState?
  var queueInformationArgument: Date?
  var recordDocumentCalled = false

  var clientAttestationErrorCalled = false
  var keyAttestationErrorCalled = false
  var validateAttestationsError: Error?
  var eIDRequestError: Error?

  var walletPairingCalled = false
  var walletPairingListCalled = false
  var avIdentityCheckCalled = false
  var avIntroSelfieVideoCalled = false
  var avDevicePairingQRCodeCalled = false
  var recordSelfieCalled = false
  var nfcScanCalled = false
  var submitEidRequestCalled = false

  /// PresentationRoutes
  var startPresentationContext: PresentationRequestContext?

  func close() {
    closeCalled = true
  }

  func close(onComplete: (() -> Void)?) {
    closeOnCompleteCalled = true
  }

  func pop() {
    popCalled = true
  }

  func pop(count: Int) {
    popCountCalled = true
  }

  func popToRoot() {
    popToRootCalled = true
  }

  func dismiss() {
    dismissCalled = true
  }

  func openExternalLink(url: URL) {
    externalLinkCalled = true
  }

  func externalSettings() {
    settingsCalled = true
  }
}


extension MockEIDRequestRouter: EIDRequestRoutes {

  func eIDRequest() {
    eidRequestCalled = true
  }

  func autoVerification(caseId: String) {
    autoVerificationArgument = caseId
  }

  func obtainConsent(caseId: String) {
    optainConsentArgument = caseId
  }
}


extension MockEIDRequestRouter: EIDRequestInternalRoutes {

  func dataPrivacy() {
    dataPrivacyCalled = true
  }

  func attestation() {
    attestationCalled = true
  }

  func legalRepresentant() {
    legalRepresentantCalled = true
  }

  func documentSelection() {
    documentSelectionCalled = true
  }

  func cameraPermission() {
    cameraPermissionCalled = true
  }

  func scanDocument() {
    scanDocumentCalled = true
  }

  func mrzMockData() {
    mrzMockDataCalled = true
  }

  func scanDocumentSubmit(_ scanDocumentOutput: ScanDocumentOutput) {
    scanDocumentCalled = true
  }

  func legalRepresentantConsent(caseId: String) {
    legalRepresentantConsentArgument = caseId
  }

  func legalRepresentantQRCode(caseId: String) {
    legalRepresentantQRCodeArgument = caseId
  }

  func legalRepresentantVerification(caseId: String) {
    legalRepresentantVerificationArgument = caseId
  }

  func legalRepresentantEIDRequest() {
    legalRepresentantEIDRequestCalled = true
  }

  func legalRepresentantConsentState(_ state: RequestCaseViewState) {
    legalRepresentantConsentStateArgument = state
  }

  func queueInformation(_ onlineSessionStartDate: Date) {
    queueInformationArgument = onlineSessionStartDate
  }

  func recordDocument() {
    recordDocumentCalled = true
  }

  func clientAttestationError() {
    clientAttestationErrorCalled = true
  }

  func keyAttestationError() {
    keyAttestationErrorCalled = true
  }

  func validateAttestationsError(delegate: any ValidateAttestationsErrorDelegate, error: Error) {
    validateAttestationsError = error
  }

  func eIDRequestError(error: Error, delegate: EIDRequestErrorDelegate) {
    eIDRequestError = error
  }

  func walletPairing() {
    walletPairingCalled = true
  }

  func walletPairingList() {
    walletPairingListCalled = true
  }

  func avIdentityCheck() {
    avIdentityCheckCalled = true
  }

  func avIntroSelfieVideo() {
    avIntroSelfieVideoCalled = true
  }

  func avDevicePairingQRCode(delegate: DevicePairingDelegate) {
    avDevicePairingQRCodeCalled = true
  }

  func recordSelfie() {
    recordSelfieCalled = true
  }

  func nfcScan() {
    nfcScanCalled = true
  }

  func submitEidRequest() {
    submitEidRequestCalled = true
  }
}

// MARK: PresentationRoutes

extension MockEIDRequestRouter: PresentationRoutes {
  func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    startPresentationContext = context
  }
}
