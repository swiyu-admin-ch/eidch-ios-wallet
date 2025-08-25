import Foundation
@testable import BITEIDRequest

final class MockEIDRequestRouter: EIDRequestRouterRoutes, EIDRequestInternalRoutes {

  var closeCalled = false
  var closeOnCompleteCalled = false
  var popCalled = false
  var popNumberCalled = false
  var popToRootCalled = false
  var dismissCalled = false
  var scanDocumentCalled = false
  var scanDocumentSubmitCalled = false
  var mrzMockDataCalled = false
  var externalLinkCalled = false
  var settingsCalled = false
  var dataPrivacyCalled = false
  var cameraPermissionCalled = false
  var queueInformationArgument: Date?
  var legalRepresentantCalled = false
  var legalRepresentantConsentArgument: String?
  var legalRepresentantQRCodeArgument: String?
  var legalRepresentantConsentStateArgument: RequestCaseViewState?
  var documentSelectionCalled = false
  var attestationCalled = false
  var walletPairingCalled = false
  var avIdentityCheckCalled = false
  var clientAttestationErrorCalled = false
  var keyAttestationErrorCalled = false
  var attestationError: Error?
  var avIntroSelfieVideoCalled = false
  var recordDocumentCalled = false
  var recordSelfieCalled = false
  var context = EIDRequestContext()

  func avIdentityCheck() {
    avIdentityCheckCalled = true
  }

  func walletPairing() {
    walletPairingCalled = true
  }

  func clientAttestationError() {
    clientAttestationErrorCalled = true
  }

  func keyAttestationError() {
    keyAttestationErrorCalled = true
  }

  func validateAttestationsError(delegate: any ValidateAttestationsErrorDelegate, error: Error) {
    attestationError = error
  }

  func dataPrivacy() {
    dataPrivacyCalled = true
  }

  func cameraPermission() {
    cameraPermissionCalled = true
  }

  func queueInformation(_ onlineSessionStartDate: Date) {
    queueInformationArgument = onlineSessionStartDate
  }

  func close(onComplete: (() -> Void)?) {
    closeOnCompleteCalled = true
  }

  func pop() {
    popCalled = true
  }

  func pop(number: Int) {
    popNumberCalled = true
  }

  func popToRoot() {
    popToRootCalled = true
  }

  func dismiss() {
    dismissCalled = true
  }

  func close() {
    closeCalled = true
  }

  func scanDocument() {
    scanDocumentCalled = true
  }

  func scanDocumentSubmit(_ scanDocumentOutput: ScanDocumentOutput) {
    scanDocumentCalled = true
  }

  func mrzMockData() {
    mrzMockDataCalled = true
  }

  func openExternalLink(url: URL) {
    externalLinkCalled = true
  }

  func settings() {
    settingsCalled = true
  }

  func legalRepresentant() {
    legalRepresentantCalled = true
  }

  func legalRepresentantConsent(caseId: String) {
    legalRepresentantConsentArgument = caseId
  }

  func legalRepresentantQRCode(caseId: String) {
    legalRepresentantQRCodeArgument = caseId
  }

  func legalRepresentantConsentState(_ state: RequestCaseViewState) {
    legalRepresentantConsentStateArgument = state
  }

  func documentSelection() {
    documentSelectionCalled = true
  }

  func attestation() {
    attestationCalled = true
  }

  func avIntroSelfieVideo() {
    avIntroSelfieVideoCalled = true
  }

  func recordDocument() {
    recordDocumentCalled = true
  }

  func recordSelfie() {
    recordSelfieCalled = true
  }
}
