import BITOpenID

extension InvitationError: Equatable {

  public static func == (lhs: InvitationError, rhs: InvitationError) -> Bool {
    switch (lhs, rhs) {
    case (.expiredInvitation, .expiredInvitation),
         (.expiredPresentationRequest, .expiredPresentationRequest),
         (.invalidQRCode, .invalidQRCode),
         (.invalidRedirectUri, .invalidRedirectUri),
         (.noConnection, .noConnection),
         (.notFoundPresentationRequest, .notFoundPresentationRequest),
         (.unauthorizedIssuance, .unauthorizedIssuance),
         (.unknownIssuer, .unknownIssuer),
         (.unknownRegistry, .unknownRegistry),
         (.unverifiedActor, .unverifiedActor),
         (.validationFailed, .validationFailed):
      true
    case (.oAuth(let lhsError), .oAuth(let rhsError)):
      lhsError == rhsError
    case (.credentialRequest(let lhsError), .credentialRequest(let rhsError)):
      lhsError == rhsError
    case (.invalidPresentationRequest(let lhsErrorCode), .invalidPresentationRequest(let rhsErrorCode)):
      lhsErrorCode == rhsErrorCode
    case (.transactionDataNotSupported(let lhsErrorCode), .transactionDataNotSupported(let rhsErrorCode)):
      lhsErrorCode == rhsErrorCode
    default:
      false
    }
  }
}
