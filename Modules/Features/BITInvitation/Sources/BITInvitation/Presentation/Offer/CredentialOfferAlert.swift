import BITL10n

// MARK: - CredentialOfferAlert

enum CredentialOfferAlert: Equatable {
  case nonCompliantActor
  case unknownIssuer

  // MARK: Internal

  var title: String {
    switch self {
    case .nonCompliantActor:
      L10n.tkReceiveCredentialOfferNonCompliantActorWarningPrimary
    case .unknownIssuer:
      L10n.tkReceiveCredentialOfferConfirmIssuancePrimary
    }
  }

  var message: String {
    switch self {
    case .nonCompliantActor:
      L10n.tkReceiveCredentialOfferNonCompliantActorWarningSecondary
    case .unknownIssuer:
      L10n.tkReceiveCredentialOfferConfirmIssuanceSecondary
    }
  }
}
