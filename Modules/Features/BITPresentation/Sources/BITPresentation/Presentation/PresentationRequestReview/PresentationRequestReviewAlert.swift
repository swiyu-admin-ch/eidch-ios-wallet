import BITL10n

// MARK: - PresentationRequestReviewAlert

enum PresentationRequestReviewAlert: Equatable {
  case unknownVerifier
  case businessExpiredCredential
  case suspendedCredential

  // MARK: Internal

  var title: String {
    switch self {
    case .unknownVerifier:
      L10n.tkPresentReviewConfirmPresentationPrimary
    case .businessExpiredCredential:
      L10n.tkPresentReviewBusinessExpiryWarningPrimary
    case .suspendedCredential:
      L10n.tkPresentReviewSuspendedWarningPrimary
    }
  }

  var message: String {
    switch self {
    case .unknownVerifier:
      L10n.tkPresentReviewConfirmPresentationSecondary
    case .businessExpiredCredential:
      L10n.tkPresentReviewBusinessExpiryWarningSecondary
    case .suspendedCredential:
      L10n.tkPresentReviewSuspendedWarningSecondary
    }
  }
}
