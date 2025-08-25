import BITCredentialShared
import BITOpenID
import Foundation
@testable import BITInvitation
@testable import BITNavigationTestCore

final class MockCredentialOfferRouter: ClosableRoutesMock, CredentialOfferRoutes, CredentialOfferInternalRoutes {

  private(set) var credentialOfferCalled = false
  private(set) var credentialOfferCredential: Credential?
  private(set) var trustStatement: TrustStatement?
  private(set) var wrongDataCalled = false
  private(set) var externalLinkCalled = false

  func credentialOffer(credential: Credential, trustStatement: TrustStatement?) {
    credentialOfferCalled = true
    credentialOfferCredential = credential
    self.trustStatement = trustStatement
  }

  func wrongData() {
    wrongDataCalled = true
  }

  func openExternalLink(url: URL) {
    externalLinkCalled = true
  }

}
