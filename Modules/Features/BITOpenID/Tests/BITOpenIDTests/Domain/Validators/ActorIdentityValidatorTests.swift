import Factory
import Testing
@testable import BITAnalytics
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

@Suite(.serialized)
struct ActorIdentityValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let trustStatementValidatorSpy = TrustStatementValidatorProtocolSpy<IdentityTrustStatementJWT>()
    self.trustStatementValidatorSpy = trustStatementValidatorSpy
    let didResolverHelperSpy = DidResolverHelperProtocolSpy()
    self.didResolverHelperSpy = didResolverHelperSpy
    let trustStatementServiceSpy = TrustStatementServiceProtocolSpy()
    self.trustStatementServiceSpy = trustStatementServiceSpy
    let analyticsProvider = MockProvider()
    self.analyticsProvider = analyticsProvider
    didResolverHelperSpy.getDidFromReturnValue = actorDidMock
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    Container.shared.trustStatementValidator.register { trustStatementValidatorSpy }
    Container.shared.didResolverHelper.register { didResolverHelperSpy }
    Container.shared.trustStatementService.register { trustStatementServiceSpy }
    Container.shared.trustEnvironmentDidRegex.register { #/^did:example:actor$/# }
    Container.shared.analytics.register { analytics }
  }

  // MARK: Internal

  @Test
  func validate_featureDisabled_ignoresIdentityTrustStatement() async throws {
    let validator = ActorIdentityValidator()

    try await validator.validate(metadataJwsMock)

    #expect(Container.shared.isActorIdentityValidationEnabled() == false)
    #expect(didResolverHelperSpy.getDidFromCallsCount == 1)
    #expect(trustStatementValidatorSpy.validateForCallsCount == 1)
    #expect(trustStatementServiceSpy.fetchIdentityForCallsCount == 0)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func validate_noIdentityTrustStatement_fetchesV1IdentityTrustStatement() async throws {
    trustStatementServiceSpy.fetchIdentityForReturnValue = IdentityTrustStatementV1JWT.Mock.validSample
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    try await validator.validate(metadataJwsWithoutIdentityTrustStatementMock)

    #expect(didResolverHelperSpy.getDidFromCallsCount == 1)
    #expect(didResolverHelperSpy.getDidFromReceivedKid == metadataJwsWithoutIdentityTrustStatementMock.header.keyIdentifier)
    #expect(trustStatementServiceSpy.fetchIdentityForCallsCount == 1)
    #expect(trustStatementServiceSpy.fetchIdentityForReceivedSubjectDid == actorDidMock)
    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func validate_trustStatementServiceThrows_throws() async {
    trustStatementServiceSpy.fetchIdentityForThrowableError = TestingError.error
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    await #expect(throws: GovernanceError.unverifiedActor) {
      try await validator.validate(metadataJwsWithoutIdentityTrustStatementMock)
    }

    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_validIdentityTrustStatement_validatesActor() async throws {
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    try await validator.validate(metadataJwsMock)

    #expect(didResolverHelperSpy.getDidFromCallsCount == 1)
    #expect(didResolverHelperSpy.getDidFromReceivedKid == metadataJwsMock.header.keyIdentifier)
    #expect(trustStatementValidatorSpy.validateForCallsCount == 1)
    #expect(trustStatementValidatorSpy.validateForReceivedTrustStatement == metadataJwsMock.payload.credentialIssuerMetadata.identityTrustStatement)
    #expect(trustStatementValidatorSpy.validateForReceivedSubjectDid == actorDidMock)
    #expect(trustStatementServiceSpy.fetchIdentityForCallsCount == 0)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func validate_didResolutionThrows_throws() async {
    didResolverHelperSpy.getDidFromThrowableError = TestingError.error
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    await #expect(throws: TestingError.error) {
      try await validator.validate(metadataJwsMock)
    }
  }

  @Test
  func validate_invalidIdentityTrustStatement_throwsUnverifiedActor() async {
    trustStatementValidatorSpy.validateForThrowingError = TestingError.error
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    await #expect(throws: GovernanceError.unverifiedActor) {
      try await validator.validate(metadataJwsMock)
    }

    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_externalActor_throwsUnknownRegistry() async {
    didResolverHelperSpy.getDidFromReturnValue = externalActorDidMock
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    await #expect(throws: GovernanceError.unknownRegistry) {
      try await validator.validate(metadataJwsMock)
    }

    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_matchingCredentialIssuerDid_validates() throws {
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    try validator.validate(
      issuerDid: actorDidMock,
      metadataJws: metadataJwsMock)

    #expect(didResolverHelperSpy.getDidFromCallsCount == 1)
    #expect(didResolverHelperSpy.getDidFromReceivedKid == metadataJwsMock.header.keyIdentifier)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func validateCredentialIssuerDid_featureFlagDisabled_returns() throws {
    let validator = ActorIdentityValidator()

    try validator.validate(
      issuerDid: externalActorDidMock,
      metadataJws: metadataJwsMock)

    #expect(didResolverHelperSpy.getDidFromCallsCount == 0)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func validateCredentialIssuerDid_didResolverThrows_throws() {
    didResolverHelperSpy.getDidFromThrowableError = TestingError.error
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    #expect(throws: TestingError.error) {
      try validator.validate(
        issuerDid: actorDidMock,
        metadataJws: metadataJwsMock)
    }
  }

  @Test
  func validate_mismatchingCredentialIssuerDid_throwsUnverifiedActor() {
    let validator = makeValidator(isActorIdentityValidationEnabled: true)

    #expect(throws: GovernanceError.unverifiedActor) {
      try validator.validate(
        issuerDid: externalActorDidMock,
        metadataJws: metadataJwsMock)
    }

    #expect(didResolverHelperSpy.getDidFromCallsCount == 1)
    #expect(didResolverHelperSpy.getDidFromReceivedKid == metadataJwsMock.header.keyIdentifier)
    #expect(analyticsProvider.logCounter == 1)
  }

  // MARK: Private

  private let metadataJwsMock = CredentialIssuerMetadataJWT.Mock.sample
  private let metadataJwsWithoutIdentityTrustStatementMock: JWS<CredentialIssuerMetadataJWT> = {
    var metadata = CredentialIssuerMetadata.Mock.sample
    metadata.identityTrustStatement = nil
    return CredentialIssuerMetadataJWT.Mock.createJWS(from: metadata)
  }()

  private let actorDidMock = "did:example:actor"
  private let externalActorDidMock = "did:example:external"

  private let trustStatementValidatorSpy: TrustStatementValidatorProtocolSpy<IdentityTrustStatementJWT>
  private let didResolverHelperSpy: DidResolverHelperProtocolSpy
  private let trustStatementServiceSpy: TrustStatementServiceProtocolSpy
  private let analyticsProvider: MockProvider

  private func makeValidator(isActorIdentityValidationEnabled: Bool) -> ActorIdentityValidator {
    Container.shared.isActorIdentityValidationEnabled.register { isActorIdentityValidationEnabled }
    return ActorIdentityValidator()
  }
}
