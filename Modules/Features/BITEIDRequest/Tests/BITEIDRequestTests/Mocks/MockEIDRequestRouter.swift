import BITAVWrapper
import BITNavigation
import Foundation
@testable import BITEIDRequest
@testable import BITPresentation


final class MockEIDRequestRouter: EIDRequestRouterRoutes, EIDRequestInternalRoutes {

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
  var walletPairingArgument: String?
  var identityCheckArgument: String?

  var legalRepresentantConsentStateArgument: RequestCaseViewState?
  var eIDRequestError: Error?

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

  func walletPairing(caseId: String) {
    walletPairingArgument = caseId
  }

  func identityCheck(caseId: String) {
    identityCheckArgument = caseId
  }
}

// MARK: PresentationRoutes

extension MockEIDRequestRouter: PresentationRoutes {
  func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    startPresentationContext = context
  }
}
