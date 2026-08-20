// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

import BITClaimsPathPointer
import Factory
import Foundation
import Testing
@testable import BITAnalytics
@testable import BITOpenID
@testable import BITTestingCore

@Suite(.serialized)
struct ValidateVerificationAuthorizationTrustStatementUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    useCase = ValidateVerificationAuthorizationTrustStatementUseCase()
  }

  // MARK: Internal

  @Test
  func call_protectedClaims_justRuns() async throws {
    try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer])

    #expect(trustStatementValidatorSpy.validateForCallsCount == 1)
    #expect(trustStatementValidatorSpy.validateForReceivedTrustStatement?.payload == trustStatementMock.payload)
    #expect(trustStatementValidatorSpy.validateForReceivedSubjectDid == clientId)
    #expect(!presentationRequestServiceSpy.declineUrlWithCalled)
  }

  @Test
  func call_multipleRequestedClaims_justRuns() async throws {
    let otherProtectedPointer: ClaimsPathPointer = [.index(0), .string(protectedClaim), .null]

    try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer, otherProtectedPointer, otherPointer])

    #expect(trustStatementValidatorSpy.validateForCallsCount == 1)
    #expect(!presentationRequestServiceSpy.declineUrlWithCalled)
  }

  @Test
  mutating func call_noProtectedClaims_justRuns() async throws {
    mockProtectedClaims([])

    try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer])

    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
    #expect(!presentationRequestServiceSpy.declineUrlWithCalled)
  }

  @Test
  func call_noRequestedClaims_justRuns() async throws {
    try await useCase(requestObject: requestObjectMock, requestedClaims: [])

    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
    #expect(!presentationRequestServiceSpy.declineUrlWithCalled)
  }

  @Test
  func call_withoutIdTSAndWithoutPvaTS_justRuns() async throws {
    try await useCase(requestObject: RequestObjectJWS.Mock.sampleWithoutVerifiedQuery.payload, requestedClaims: [pointer])

    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
    #expect(!presentationRequestServiceSpy.declineUrlWithCalled)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func call_withoutIdTSAndWithPvaTS_ignoresPvaTS() async throws {
    try await useCase(requestObject: RequestObjectJWS.Mock.sampleWithProtectedClaimsWithoutIdentityTrust.payload, requestedClaims: [pointer])

    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
    #expect(!presentationRequestServiceSpy.declineUrlWithCalled)
    #expect(analyticsProvider.logCounter == 0)
  }

  @Test
  func call_protectedClaimsWithoutTrustStatement_throws() async {
    let jws = RequestObjectJWS.Mock.sample

    await #expect(
      throws: ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification())
    {
      try await useCase(requestObject: jws.payload, requestedClaims: [pointer])
    }
    #expect(presentationRequestServiceSpy.declineUrlWithCallsCount == 1)
    #expect(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.url == URL(string: "https://eid.admin.ch/response"))
    #expect(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.error == .accessDenied)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  mutating func call_trustStatementHasOtherClaims_throws() async {
    mockProtectedClaims(["other"])

    await #expect(
      throws: ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification())
    {
      try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer, [.string("other")]])
    }
    #expect(presentationRequestServiceSpy.declineUrlWithCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func call_validatorThrows_throwsUnauthorizedVerification() async {
    trustStatementValidatorSpy.validateForThrowingError = TestingError.error

    await #expect(
      throws: ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification())
    {
      try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer])
    }
    #expect(presentationRequestServiceSpy.declineUrlWithCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func call_declineThrows_ignoresDeclineError() async {
    trustStatementValidatorSpy.validateForThrowingError = TrustStatementServiceError.validationFailed
    presentationRequestServiceSpy.declineUrlWithThrowableError = TestingError.error

    await #expect(
      throws: ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification())
    {
      try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer])
    }
    #expect(presentationRequestServiceSpy.declineUrlWithCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func call_declineWithPresentationResponse_throwsWithResponse() async {
    let presentationResponse = PresentationResponse(redirectUri: URL(string: "https://verifier.ch"))
    trustStatementValidatorSpy.validateForThrowingError = TrustStatementServiceError.validationFailed
    presentationRequestServiceSpy.declineUrlWithReturnValue = presentationResponse

    await #expect(
      throws: ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification(
        presentationResponse: presentationResponse))
    {
      try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer])
    }
  }

  @Test
  func call_declineWithInvalidRedirectUri_throwsInvalidRedirectUri() async {
    trustStatementValidatorSpy.validateForThrowingError = TrustStatementServiceError.validationFailed
    presentationRequestServiceSpy.declineUrlWithThrowableError = PresentationResponseValidationError.invalidRedirectUri

    await #expect(throws: PresentationResponseValidationError.invalidRedirectUri) {
      try await useCase(requestObject: requestObjectMock, requestedClaims: [pointer])
    }
    #expect(analyticsProvider.logCounter == 1)
  }

  // MARK: Private

  private let protectedClaim = "field_1"
  private let otherClaim = "other"
  private let clientId = "did:example:12345"

  private var requestObjectMock: RequestObject = RequestObjectJWS.Mock.sampleWithProtectedClaims.payload
  private let trustStatementMock = ProtectedVerificationAuthorizationTrustStatementJWT.Mock.sample

  private var trustStatementValidatorSpy: TrustStatementValidatorProtocolSpy<ProtectedVerificationAuthorizationTrustStatementJWT>!
  private var presentationRequestServiceSpy: PresentationRequestServiceProtocolSpy!
  private var analyticsProvider: MockProvider!

  private var useCase: ValidateVerificationAuthorizationTrustStatementUseCase!

  private var pointer: ClaimsPathPointer {
    [.string(protectedClaim)]
  }

  private var otherPointer: ClaimsPathPointer {
    [.string(otherClaim)]
  }

  private mutating func registerMocks() {
    let trustStatementValidatorSpy = TrustStatementValidatorProtocolSpy<ProtectedVerificationAuthorizationTrustStatementJWT>()
    let presentationRequestServiceSpy = PresentationRequestServiceProtocolSpy()
    let analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    self.trustStatementValidatorSpy = trustStatementValidatorSpy
    self.presentationRequestServiceSpy = presentationRequestServiceSpy
    self.analyticsProvider = analyticsProvider
    let protectedClaims = [protectedClaim]

    Container.shared.trustStatementValidator.register { trustStatementValidatorSpy }
    Container.shared.presentationRequestService.register { presentationRequestServiceSpy }
    Container.shared.protectedVerificationClaims.register { protectedClaims }
    Container.shared.analytics.register { analytics }
  }

  private mutating func mockProtectedClaims(_ claims: [String]? = nil) {
    let protectedClaims = claims ?? [protectedClaim]
    Container.shared.protectedVerificationClaims.register { protectedClaims }
    useCase = ValidateVerificationAuthorizationTrustStatementUseCase()
  }
}
