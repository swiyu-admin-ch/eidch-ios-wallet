import BITL10n

// MARK: - PresentationRequestReviewAlert

enum PresentationRequestReviewAlert: Equatable {
  case unknownVerifier
  case nonCompliantActor
  case businessExpiredCredential
  case suspendedCredential
  case unregisteredRequest

  // MARK: Internal

  var title: String {
    switch self {
    case .unknownVerifier:
      L10n.tkPresentReviewConfirmPresentationPrimary
    case .nonCompliantActor:
      L10n.tkPresentReviewNonCompliantActorWarningPrimary
    case .businessExpiredCredential:
      L10n.tkPresentReviewBusinessExpiryWarningPrimary
    case .suspendedCredential:
      L10n.tkPresentReviewSuspendedWarningPrimary
    case .unregisteredRequest:
      L10n.tkPresentReviewUnregisteredRequestWarningPrimary
    }
  }

  var message: String {
    switch self {
    case .unknownVerifier:
      L10n.tkPresentReviewConfirmPresentationSecondary
    case .nonCompliantActor:
      L10n.tkPresentReviewNonCompliantActorWarningSecondary
    case .businessExpiredCredential:
      L10n.tkPresentReviewBusinessExpiryWarningSecondary
    case .suspendedCredential:
      L10n.tkPresentReviewSuspendedWarningSecondary
    case .unregisteredRequest:
      L10n.tkPresentReviewUnregisteredRequestWarningSecondary
    }
  }
}
