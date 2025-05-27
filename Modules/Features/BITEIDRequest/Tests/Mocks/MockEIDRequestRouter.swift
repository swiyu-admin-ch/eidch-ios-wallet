import Foundation
@testable import BITEIDRequest

final class MockEIDRequestRouter: EIDRequestRouterRoutes, EIDRequestInternalRoutes {

  var closeCalled = false
  var closeOnCompleteCalled = false
  var checkCardIntroductionCalled = false
  var popCalled = false
  var popNumberCalled = false
  var popToRootCalled = false
  var dismissCalled = false
  var mrzScannerCalled = false
  var externalLinkCalled = false
  var settingsCalled = false
  var dataPrivacyCalled = false
  var cameraPermissionCalled = false
  var queueInformationArgument: Date?
  var legalRepresentantCalled = false
  var legalRepresentantConsentArgument: String?
  var legalRepresentantQRCodeArgument: String?

  func checkCardIntroduction() {
    checkCardIntroductionCalled = true
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

  func mrzScanner() {
    mrzScannerCalled = true
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
}
