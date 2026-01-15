import BITCredential
import BITCredentialShared
import BITNavigation

// MARK: - CredentialOfferRoutes

public protocol CredentialOfferRoutes {
  func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation?)
}

extension CredentialOfferRoutes {
  public func credentialOffer(credential: VerifiableCredential) {
    credentialOffer(credential: credential, trustInformation: nil)
  }
}

// MARK: - CredentialOfferInternalRoutes

protocol CredentialOfferInternalRoutes: ClosableRoutes, ExternalRoutes {
  func wrongData()
  func badgeInformation(badgeType: BadgeType)
}
