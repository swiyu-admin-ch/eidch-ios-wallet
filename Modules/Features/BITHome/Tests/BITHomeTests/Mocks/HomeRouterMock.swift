import BITCredentialShared
import BITHome
import BITInvitation
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
  var didCallWalletPairingArgument: String?

  func deeplink(url: URL, animated: Bool) -> Bool {
    didCallDeeplink = true
    return true
  }

  func invitation(delegate: InvitationDelegate?) {
    didCallInvitation = true
  }

  func camera(openingStyle: OpeningStyle, delegate: InvitationDelegate?) {
    didCallCamera = true
  }

  func settings() {
    didCallSettings = true
  }

  func openExternalLink(url: URL) {
    didCallExternalLinkUrl = true
  }

  func credentialDetail(_ credential: VerifiableCredential) {
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

  func walletPairing(caseId: String) {
    didCallWalletPairingArgument = caseId
  }

}
