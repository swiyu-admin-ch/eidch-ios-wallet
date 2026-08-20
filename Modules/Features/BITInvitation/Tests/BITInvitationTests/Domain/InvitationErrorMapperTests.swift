import BITNetworking
import BITOpenID
import Testing
@testable import BITInvitation

// MARK: - InvitationErrorMapperTests

@Suite("InvitationErrorMapper")
struct InvitationErrorMapperTests {

  // MARK: Internal

  // MARK: Already mapped errors

  @Test("An already mapped InvitationError is returned untouched", arguments: [
    InvitationError.expiredInvitation,
    .noConnection,
    .unknownIssuer,
    .unauthorizedIssuance,
    .expiredPresentationRequest,
    .invalidRedirectUri,
    .notFoundPresentationRequest,
    .oAuth(.expiredAccessToken),
    .credentialRequest(.invalidNonce("invalid_nonce")),
    .invalidPresentationRequest("invalid_request"),
    .transactionDataNotSupported("transaction_data"),
  ])
  func alreadyMappedErrorIsReturnedUntouched(_ error: InvitationError) {
    #expect(map(error) as? InvitationError == error)
  }

  @Test("An already wrapped error is not wrapped a second time")
  func alreadyWrappedErrorIsNotWrappedTwice() throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(InvitationError.invalidQRCode(SampleError.sample))))
    #expect(underlying as? SampleError == .sample)
  }

  // MARK: PresentationResponseValidationError

  @Test("An invalid redirect URI is mapped to invalidRedirectUri")
  func invalidRedirectUriIsMappedToInvalidRedirectUri() {
    #expect(map(PresentationResponseValidationError.invalidRedirectUri) as? InvitationError == .invalidRedirectUri)
  }

  // MARK: OpenIdRepositoryError

  @Test("An invalid credential is mapped to validationFailed")
  func invalidCredentialIsMappedToValidationFailed() {
    #expect(map(OpenIdRepositoryError.invalidCredential) as? InvitationError == .validationFailed)
  }

  @Test("OAuth errors are mapped to oAuth", arguments: [
    OpenIdRepositoryError.expiredAccessToken,
    .insufficientScope("insufficient_scope"),
    .invalidClient("invalid_client"),
    .invalidDPoPProof("invalid_dpop_proof"),
    .invalidGrant("invalid_grant"),
    .invalidRequest("invalid_request"),
    .invalidScope("invalid_scope"),
    .invalidToken("invalid_token"),
    .unauthorizedClient("unauthorized_client"),
    .unsupportedGrantType("unsupported_grant_type"),
    .useDPoPNonce("use_dpop_nonce", "nonce"),
  ])
  func oAuthErrorsAreMappedToOAuth(_ error: OpenIdRepositoryError) {
    #expect(map(error) as? InvitationError == .oAuth(error))
  }

  @Test("Credential request errors are mapped to credentialRequest", arguments: [
    OpenIdRepositoryError.credentialRequestDenied("credential_request_denied"),
    .invalidCredentialRequest("invalid_credential_request"),
    .invalidEncryptionParameters("invalid_encryption_parameters"),
    .invalidNonce("invalid_nonce"),
    .invalidProof("invalid_proof"),
    .invalidTransactionId("invalid_transaction_id"),
    .unknownCredentialConfiguration("unknown_credential_configuration"),
    .unknownCredentialIdentifier("unknown_credential_identifier"),
  ])
  func credentialRequestErrorsAreMappedToCredentialRequest(_ error: OpenIdRepositoryError) {
    #expect(map(error) as? InvitationError == .credentialRequest(error))
  }

  @Test("Issuer metadata errors are mapped to invalidQRCode and keep the underlying error", arguments: [
    OpenIdRepositoryError.invalidCredentialIssuerMetadata,
    .invalidCredentialIssuerMetadataJWT,
    .invalidOpenIdConfigurationJWT,
    .missingCredentialResponsePrivateKey,
    .missingDeferredCredentialEndpoint,
    .missingImmediateCredentialData,
    .unencryptedCredentialResponse,
    .unsupportedCredentialStatusCode,
  ])
  func issuerMetadataErrorsAreMappedToInvalidQRCode(_ error: OpenIdRepositoryError) throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(error)))
    #expect(underlying as? OpenIdRepositoryError == error)
  }

  // MARK: NetworkError

  @Test("Connectivity network errors are mapped to noConnection", arguments: [
    NetworkErrorStatus.noConnection,
    .timeout,
  ])
  func connectivityNetworkErrorsAreMappedToNoConnection(_ status: NetworkErrorStatus) {
    #expect(map(NetworkError(status: status)) as? InvitationError == .noConnection)
  }

  @Test("Other network errors are mapped to invalidQRCode and keep the network status", arguments: [
    NetworkErrorStatus.badRequest,
    .unauthorized,
    .notFound,
    .internalServerError,
    .hostnameNotFound,
    .pinning,
    .unknown(message: "something went wrong"),
  ])
  func otherNetworkErrorsAreMappedToInvalidQRCode(_ status: NetworkErrorStatus) throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(NetworkError(status: status))))
    #expect((underlying as? NetworkError)?.status == status)
  }

  // MARK: FetchAnyVerifiableCredentialError

  @Test("Credential fetch errors are mapped to their dedicated case", arguments: [
    (FetchAnyVerifiableCredentialError.expiredInvitation, InvitationError.expiredInvitation),
    (.unknownIssuer, .unknownIssuer),
    (.validationFailed, .validationFailed),
  ])
  func credentialFetchErrorsAreMappedToTheirDedicatedCase(_ error: FetchAnyVerifiableCredentialError, _ expected: InvitationError) {
    #expect(map(error) as? InvitationError == expected)
  }

  @Test("Remaining credential fetch errors are mapped to invalidQRCode and keep the underlying error", arguments: [
    FetchAnyVerifiableCredentialError.credentialEndpointCreationError,
    .invalidVcSchema,
    .missingTypeMetadata,
    .missingVctIntegrity,
    .selectedCredentialNotFound,
    .unsupportedAlgorithm,
    .unsupportedKeyStorage,
    .vctMismatch,
  ])
  func remainingCredentialFetchErrorsAreMappedToInvalidQRCode(_ error: FetchAnyVerifiableCredentialError) throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(error)))
    #expect(String(describing: underlying) == String(describing: error))
  }

  // MARK: FetchPresentationRequestUseCaseError

  @Test("Presentation request errors are mapped to their dedicated case", arguments: [
    (FetchPresentationRequestUseCaseError.invalidRequest("invalid_request"), InvitationError.invalidPresentationRequest("invalid_request")),
    (.transactionDataNotSupported("transaction_data"), .transactionDataNotSupported("transaction_data")),
    (.unverifiedActor(), .invalidPresentationRequest("unverified_actor")),
    (.unknownRegistry(), .invalidPresentationRequest("unknown_registry")),
    (.expired, .expiredPresentationRequest),
    (.notFound, .notFoundPresentationRequest),
  ])
  func presentationRequestErrorsAreMappedToTheirDedicatedCase(_ error: FetchPresentationRequestUseCaseError, _ expected: InvitationError) {
    #expect(map(error) as? InvitationError == expected)
  }

  @Test("An invalid presentation request url is mapped to invalidQRCode and keeps the underlying error")
  func invalidPresentationRequestUrlIsMappedToInvalidQRCode() throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(FetchPresentationRequestUseCaseError.invalidUrl)))
    #expect(underlying as? FetchPresentationRequestUseCaseError == .invalidUrl)
  }

  // MARK: StartProximityEngagementUseCaseError

  @Test("Proximity engagement errors are mapped to their dedicated case", arguments: [
    (StartProximityEngagementUseCaseError.invalidRequest("invalid_request"), InvitationError.invalidPresentationRequest("invalid_request")),
    (.transactionDataNotSupported("transaction_data"), .transactionDataNotSupported("transaction_data")),
    (.expired, .expiredPresentationRequest),
    (.notFound, .notFoundPresentationRequest),
  ])
  func proximityEngagementErrorsAreMappedToTheirDedicatedCase(_ error: StartProximityEngagementUseCaseError, _ expected: InvitationError) {
    #expect(map(error) as? InvitationError == expected)
  }

  @Test("An invalid proximity origin is mapped to invalidQRCode and keeps the underlying error")
  func invalidProximityOriginIsMappedToInvalidQRCode() throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(StartProximityEngagementUseCaseError.invalidOrigin)))
    #expect(underlying as? StartProximityEngagementUseCaseError == .invalidOrigin)
  }

  // MARK: GovernanceError

  @Test("Governance errors are mapped to their dedicated case", arguments: [
    (GovernanceError.unverifiedActor, InvitationError.unverifiedActor),
    (.unknownRegistry, .unknownRegistry),
    (.unauthorizedIssuance, .unauthorizedIssuance),
  ])
  func governanceErrorsAreMappedToTheirDedicatedCase(_ error: GovernanceError, _ expected: InvitationError) {
    #expect(map(error) as? InvitationError == expected)
  }

  @Test("Unhandled governance errors are mapped to invalidQRCode and keep the underlying error", arguments: [
    GovernanceError.invalidEnvironment,
    .unauthorizedVerification,
  ])
  func unhandledGovernanceErrorsAreMappedToInvalidQRCode(_ error: GovernanceError) throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(error)))
    #expect(underlying as? GovernanceError == error)
  }

  // MARK: Fallback

  @Test("An unknown error is mapped to invalidQRCode and keeps the underlying error")
  func unknownErrorIsMappedToInvalidQRCode() throws {
    let underlying = try #require(invalidQRCodeUnderlying(map(SampleError.sample)))
    #expect(underlying as? SampleError == .sample)
  }

  // MARK: Private

  private enum SampleError: Error, Equatable {
    case sample
  }

  private let map = InvitationErrorMapper()

  private func invalidQRCodeUnderlying(_ error: Error) -> Error? {
    guard case .invalidQRCode(let underlying) = error as? InvitationError else { return nil }
    return underlying
  }

}
