import BITCredentialShared
import BITHome
import BITNavigation
import Foundation

class HomeRouterMock: HomeRouterRoutes {

  var didCallDeeplink = false
  var didCallInvitation = false
  var didCallCamera = false
  var didCallSettings = false
  var didCallExternalLinkUrl = false
  var didCallOpenCredentialDetail = false
  var didCallBetaId = false
  var didCallEIDRequest = false
  var didCallAutoVerificationArgument: String?
  var didCallObtainConsentArgument: String?

  func deeplink(url: URL, animated: Bool) -> Bool {
    didCallDeeplink = true
    return true
  }

  func invitation() {
    didCallInvitation = true
  }

  func camera(openingStyle: OpeningStyle) {
    didCallCamera = true
  }

  func settings() {
    didCallSettings = true
  }

  func openExternalLink(url: URL) {
    didCallExternalLinkUrl = true
  }

  func credentialDetail(_ credential: Credential) {
    didCallOpenCredentialDetail = true
  }

  func betaId() {
    didCallBetaId = true
  }

  func eIDRequest() {
    didCallEIDRequest = true
  }

  func autoVerification(caseId: String) {
    didCallAutoVerificationArgument = caseId
  }

  func obtainConsent(caseId: String) {
    didCallObtainConsentArgument = caseId
  }

}
