import BITAppAuth
import BITCredential
import BITCredentialShared
import BITInvitation
import BITNavigation
import BITOpenID
import BITPresentation
import Foundation
@testable import BITNavigationTestCore

class InvitationRouterMock: ClosableRoutesMock, InvitationRouterRoutes, ExternalRoutes, LoginRoutes {
  var didCallCredentialOffer = false
  var didCallDeeplink = false
  var didCallInvitation = false
  var didCallCamera = false
  var didCallExternalSettings = false
  var didCallExternalLinkComplete = false
  var didCallCompatibleCredentials = false
  var didCallPresentationReview = false
  var didCallPresentationResultState = false
  var didCallWrongData = false
  var didCallBetaId = false
  var didCallStartPresentation = false
  var didCallLogin = false

  func startPresentation(context: PresentationRequestContext, delegate: (any PresentationFinishDelegate)?) throws {
    didCallStartPresentation = true
  }

  func externalSettings() {
    didCallExternalSettings = true
  }

  func camera(openingStyle: OpeningStyle, delegate: InvitationDelegate?) {
    didCallCamera = true
  }

  func invitation(delegate: InvitationDelegate?) {
    didCallInvitation = true
  }

  func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation?, delegate: InvitationDelegate?) {
    didCallCredentialOffer = true
  }

  func deeplink(url: URL, animated: Bool) -> Bool {
    didCallDeeplink = true
    return true
  }

  func wrongData() {
    didCallWrongData = true
  }

  func betaId() {
    didCallBetaId = true
  }

  func openExternalLink(url: URL, onComplete: (() -> Void)?) {
    didCallExternalLinkComplete = true
    onComplete?()
  }

  func login(animated: Bool) {
    didCallLogin = true
  }
}
