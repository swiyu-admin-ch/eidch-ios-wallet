import BITCredential
import BITCredentialShared
import BITNavigation

// MARK: - CredentialOfferRoutes

public protocol CredentialOfferRoutes {
  func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation)
}

// MARK: - CredentialOfferInternalRoutes

protocol CredentialOfferInternalRoutes: ClosableRoutes, ExternalRoutes {
  func wrongData()
  func badgeInformation(badgeType: BadgeType)
}
