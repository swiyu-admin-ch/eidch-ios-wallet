import Factory
import Foundation

// MARK: - InvitationType

public enum InvitationType {
  case credentialOffer
  case presentation
  case proximityEngagement
}

extension InvitationType {

  // MARK: Public

  public var schemes: [String] {
    switch self {
    case .credentialOffer:
      Self.credentialOfferStandardSchemes + Container.shared.additionalCredentialOfferSchemes()
    case .presentation:
      Self.presentationStandardSchemes + Container.shared.additionalPresentationSchemes()
    case .proximityEngagement:
      Self.proximityPresentationStandardSchemes
    }
  }

  // MARK: Private

  private static let presentationStandardSchemes = ["https", "openid4vp"]
  private static let proximityPresentationStandardSchemes = ["mdoc"]
  private static let credentialOfferStandardSchemes = ["openid-credential-offer"]
}
