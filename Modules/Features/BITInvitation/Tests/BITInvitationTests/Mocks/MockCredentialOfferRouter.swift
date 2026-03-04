import BITCredential
import BITCredentialShared
import BITOpenID
import Foundation
@testable import BITInvitation
@testable import BITNavigationTestCore

final class MockCredentialOfferRouter: ClosableRoutesMock, CredentialOfferRoutes, CredentialOfferInternalRoutes {

  private(set) var credentialOfferCalled = false
  private(set) var credentialOfferCredential: VerifiableCredential?
  private(set) var trustInformation: TrustInformation?
  private(set) var wrongDataCalled = false
  private(set) var externalLinkCalled = false
  private(set) var didCallBadgeInformation = false

  func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation?, delegate: InvitationDelegate?) {
    credentialOfferCalled = true
    credentialOfferCredential = credential
    self.trustInformation = trustInformation
  }

  func wrongData() {
    wrongDataCalled = true
  }

  func openExternalLink(url: URL) {
    externalLinkCalled = true
  }

  func badgeInformation(badgeType: BadgeType) {
    didCallBadgeInformation = true
  }

}
