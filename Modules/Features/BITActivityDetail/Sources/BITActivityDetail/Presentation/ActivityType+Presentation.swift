import BITActivity
import BITL10n

extension ActivityType {
  var actorTitle: String {
    switch self {
    case .issuance: L10n.tkActivityActivityDetailIssuerTitle
    case .presentationAccepted,
         .presentationDeclined: L10n.tkActivityActivityDetailVerifierTitle
    }
  }

  var reportActorButtonTitle: String {
    switch self {
    case .issuance: L10n.tkActivityActivityDetailReportIssuerButton
    case .presentationAccepted,
         .presentationDeclined: L10n.tkActivityActivityDetailReportVerifierButton
    }
  }

  var actorTrustFooter: String {
    switch self {
    case .issuance: L10n.tkActivityActivityDetailTrustInfoFooterIssuer
    case .presentationAccepted,
         .presentationDeclined: L10n.tkActivityActivityDetailTrustInfoFooterVerifier
    }
  }

  var credentialInfoTitle: String? {
    switch self {
    case .issuance: nil
    case .presentationAccepted,
         .presentationDeclined: L10n.tkActivityActivityDetailCredentialInfoTitleVerification
    }
  }
}
