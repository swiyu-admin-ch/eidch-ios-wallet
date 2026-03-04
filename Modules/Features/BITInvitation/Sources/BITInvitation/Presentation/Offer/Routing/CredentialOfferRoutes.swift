import BITCredential
import BITCredentialShared
import BITNavigation

// MARK: - CredentialOfferRoutes

public protocol CredentialOfferRoutes {
  func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation?, delegate: InvitationDelegate?)
}

extension CredentialOfferRoutes {
  public func credentialOffer(credential: VerifiableCredential, delegate: InvitationDelegate?) {
    credentialOffer(credential: credential, trustInformation: nil, delegate: delegate)
  }
}

// MARK: - CredentialOfferInternalRoutes

protocol CredentialOfferInternalRoutes: ClosableRoutes, ExternalRoutes {
  func wrongData()
  func badgeInformation(badgeType: BadgeType)
}
