import BITCredentialShared
import BITInvitation
import BITNavigation
import BITOpenID
import BITPresentation
import Foundation
@testable import BITNavigationTestCore

class InvitationRouterMock: ClosableRoutesMock, InvitationRouterRoutes, ExternalRoutes {

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

  func compatibleCredentials(for inputDescriptorId: String, and context: PresentationRequestContext) throws {
    didCallCompatibleCredentials = true
  }

  func presentationReview(with context: PresentationRequestContext) {
    didCallPresentationReview = true
  }

  func presentationResultState(with state: BITPresentation.PresentationRequestResultState, context: BITPresentation.PresentationRequestContext) {
    didCallPresentationResultState = true
  }

  func externalSettings() {
    didCallExternalSettings = true
  }

  func camera(openingStyle: any OpeningStyle) {
    didCallCamera = true
  }

  func invitation() {
    didCallInvitation = true
  }

  func credentialOffer(credential: Credential, trustStatement: TrustStatement?) {
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

}
