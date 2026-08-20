import BITOpenID

public enum InvitationError: Error {
  /// network
  case noConnection
  case oAuth(OpenIdRepositoryError)

  /// credential
  case expiredInvitation
  case unknownIssuer
  case validationFailed
  case unverifiedActor
  case unknownRegistry
  case unauthorizedIssuance
  case invalidQRCode(_ underlyingError: Error? = nil)
  case credentialRequest(OpenIdRepositoryError)

  /// presentation
  case invalidPresentationRequest(String)
  case transactionDataNotSupported(String)
  case invalidRedirectUri
  case notFoundPresentationRequest
  case expiredPresentationRequest
}
