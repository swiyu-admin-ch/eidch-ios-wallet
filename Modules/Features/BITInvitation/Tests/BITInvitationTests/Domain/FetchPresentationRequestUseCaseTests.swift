import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITCore
@testable import BITCredential
@testable import BITInvitation
@testable import BITNonCompliance
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// swiftlint:disable force_unwrapping

@Suite(.container)
struct FetchPresentationRequestUseCaseTests {

  // MARK: Lifecycle

  init() {
    let serviceSpy = PresentationRequestServiceProtocolSpy()
    self.serviceSpy = serviceSpy
    serviceSpy.fetchFromReturnValue = requestObjectJWSMock

    let getCompatibleCredentialsUseCaseSpy = GetCompatibleCredentialsUseCaseProtocolSpy()
    self.getCompatibleCredentialsUseCaseSpy = getCompatibleCredentialsUseCaseSpy
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = compatibleCredentialsMock

    let trustInformationServiceSpy = TrustInformationServiceProtocolSpy()
    self.trustInformationServiceSpy = trustInformationServiceSpy
    trustInformationServiceSpy.fetchForTypeVcSchemaIdReturnValue = trustInformationMock
    trustInformationServiceSpy.getEntityNamesForReturnValue = legacyVerifierNamesMock

    let nonComplianceRepositorySpy = NonComplianceRepositoryProtocolSpy()
    self.nonComplianceRepositorySpy = nonComplianceRepositorySpy
    nonComplianceRepositorySpy.fetchActorComplianceForReturnValue = actorComplianceMock

    let actorIdentityValidatorSpy = ActorIdentityValidatorProtocolSpy()
    self.actorIdentityValidatorSpy = actorIdentityValidatorSpy

    Container.shared.presentationRequestService.register { serviceSpy }
    Container.shared.getCompatibleCredentialsUseCase.register { getCompatibleCredentialsUseCaseSpy }
    Container.shared.trustInformationService.register { trustInformationServiceSpy }
    Container.shared.actorIdentityValidator.register { actorIdentityValidatorSpy }
    Container.shared.nonComplianceRepository.register { nonComplianceRepositorySpy }

    useCase = FetchPresentationRequestUseCase()
  }

  // MARK: Internal

  @Test
  func execute_requestObjectOneCredential_argumentsPassed() async throws {
    _ = try await useCase(url: urlMock)

    #expect(serviceSpy.fetchFromCallsCount == 1)
    #expect(serviceSpy.fetchFromReceivedUrl == urlMock)
    #expect(serviceSpy.declineUrlWithCallsCount == 0)

    #expect(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount == 1)
    #expect(
      getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReceivedRequestObject
        == Self.requestObjectMock.payload)

    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount == 0)
    #expect(trustInformationServiceSpy.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)
    #expect(actorIdentityValidatorSpy.validateForCallsCount == 1)
    #expect(actorIdentityValidatorSpy.validateForReceivedArguments?.identityTrustStatement == Self.requestObjectMock.payload.identityTrustStatement)
    #expect(actorIdentityValidatorSpy.validateForReceivedArguments?.actorDid == Self.requestObjectMock.payload.clientIdentifier.clientId)

    #expect(nonComplianceRepositorySpy.fetchActorComplianceForCallsCount == 1)
    #expect(
      nonComplianceRepositorySpy.fetchActorComplianceForReceivedSubjectDid
        == Self.requestObjectMock.payload.clientIdentifier.clientId)
  }

  @Test
  func execute_requestObjectNoIdentityTrustStatement_argumentsPassed() async throws {
    serviceSpy.fetchFromReturnValue = RequestObjectJWS.Mock.withoutIdentityTrust

    _ = try await useCase(url: urlMock)

    #expect(serviceSpy.fetchFromCallsCount == 1)
    #expect(serviceSpy.fetchFromReceivedUrl == urlMock)
    #expect(serviceSpy.declineUrlWithCallsCount == 0)

    #expect(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount == 1)
    #expect(
      getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReceivedRequestObject
        == RequestObjectJWS.Mock.withoutIdentityTrust.payload)

    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount == 1)
    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId == nil)
    #expect(trustInformationServiceSpy.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)
    #expect(nonComplianceRepositorySpy.fetchActorComplianceForCallsCount == 1)
    #expect(actorIdentityValidatorSpy.validateForCallsCount == 1)
    #expect(actorIdentityValidatorSpy.validateForReceivedArguments?.identityTrustStatement == nil)
    #expect(actorIdentityValidatorSpy.validateForReceivedArguments?.actorDid == RequestObjectJWS.Mock.withoutIdentityTrust.payload.clientIdentifier.clientId)
    #expect(trustInformationServiceSpy.getEntityNamesForCallsCount == 1)
  }

  @Test
  func execute_requestObjectWithClientIdPrefix_returnsContextWithTrustStatement() async throws {
    let requestObject = RequestObjectJWS.Mock.clientIdDIDPrefix
    serviceSpy.fetchFromReturnValue = requestObject

    let context = try await useCase(url: urlMock)

    #expect(context.requestObject == requestObject.payload)
    #expect(context.compatibleCredentials == compatibleCredentialsMock)
    #expect(context.selectedCredential == compatibleCredentialsMock.first)
    #expect(context.trustInformation == trustInformationMock)
    #expect(context.actorCompliance == actorComplianceMock)
  }

  @Test
  func execute_requestObjectOneCredential_returnsContext() async throws {
    let context = try await useCase(url: urlMock)

    #expect(context.requestObject == Self.requestObjectMock.payload)
    #expect(context.compatibleCredentials == compatibleCredentialsMock)
    #expect(context.selectedCredential == compatibleCredentialsMock.first)
    #expect(context.trustInformation == trustInformationMock)
    #expect(context.actorCompliance == actorComplianceMock)
  }

  @Test
  func execute_requestObjectNoIdentityTrustStatement_returnsContext() async throws {
    serviceSpy.fetchFromReturnValue = RequestObjectJWS.Mock.withoutIdentityTrust

    let context = try await useCase(url: urlMock)

    #expect(context.requestObject == RequestObjectJWS.Mock.withoutIdentityTrust.payload)
    #expect(context.compatibleCredentials == compatibleCredentialsMock)
    #expect(context.selectedCredential == compatibleCredentialsMock.first)
    #expect(context.trustInformation == trustInformationMock)
  }

  @Test
  func execute_requestObjectMultipleCredentials_argumentsPassed() async throws {
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = CompatibleCredential.Mock.array

    _ = try await useCase(url: urlMock)

    #expect(serviceSpy.fetchFromCallsCount == 1)
    #expect(serviceSpy.fetchFromReceivedUrl == urlMock)
    #expect(serviceSpy.declineUrlWithCallsCount == 0)

    #expect(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount == 1)
    #expect(
      getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReceivedRequestObject
        == Self.requestObjectMock.payload)

    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount == 0)
    #expect(trustInformationServiceSpy.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)

    #expect(nonComplianceRepositorySpy.fetchActorComplianceForCallsCount == 1)
    #expect(
      nonComplianceRepositorySpy.fetchActorComplianceForReceivedSubjectDid
        == Self.requestObjectMock.payload.clientIdentifier.clientId)
  }

  @Test
  func execute_requestObjectMultipleCredentials_returnsContext() async throws {
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = CompatibleCredential.Mock.array

    let context = try await useCase(url: urlMock)

    #expect(context.requestObject == Self.requestObjectMock.payload)
    #expect(context.compatibleCredentials == CompatibleCredential.Mock.array)
    #expect(context.selectedCredential == nil)
    #expect(context.trustInformation == trustInformationMock)
    #expect(context.actorCompliance == actorComplianceMock)
  }

  @Test
  func execute_jwtRequestObject_argumentsPassed() async throws {
    serviceSpy.fetchFromReturnValue = requestObjectJWSMock

    _ = try await useCase(url: urlMock)

    #expect(serviceSpy.fetchFromCallsCount == 1)
    #expect(serviceSpy.fetchFromReceivedUrl == urlMock)
    #expect(serviceSpy.declineUrlWithCallsCount == 0)

    #expect(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount == 1)
    #expect(
      getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReceivedRequestObject
        == Self.requestObjectMock.payload)

    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount == 0)
    #expect(trustInformationServiceSpy.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)

    #expect(nonComplianceRepositorySpy.fetchActorComplianceForCallsCount == 1)
    #expect(
      nonComplianceRepositorySpy.fetchActorComplianceForReceivedSubjectDid
        == requestObjectJWSMock.payload.clientIdentifier.clientId)
  }

  @Test
  func execute_jwtRequestObject_returnsContextWithTrustStatement() async throws {
    serviceSpy.fetchFromReturnValue = requestObjectJWSMock

    let context = try await useCase(url: urlMock)

    let requestObject = requestObjectJWSMock.payload
    #expect(context.requestObject == requestObject)
    #expect(context.compatibleCredentials == compatibleCredentialsMock)
    #expect(context.selectedCredential == compatibleCredentialsMock.first)
    #expect(context.trustInformation == trustInformationMock)
    #expect(context.actorCompliance == actorComplianceMock)
  }

  @Test
  func execute_jwtRequestObjectWithoutVct_doesNotFetchVcSchemaTrust() async throws {
    let requestObject = RequestObjectJWS.Mock.noVct
    serviceSpy.fetchFromReturnValue = requestObject

    let context = try await useCase(url: urlMock)

    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount == 1)
    #expect(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId == nil)
    #expect(trustInformationServiceSpy.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)
    #expect(context.trustInformation == trustInformationMock)
    #expect(context.actorCompliance == actorComplianceMock)
  }

  @Test
  func execute_invalidActorIdentity_throwsUnverifiedActor() async {
    actorIdentityValidatorSpy.validateForThrowableError = GovernanceError.unverifiedActor

    await #expect(throws: FetchPresentationRequestUseCaseError.unverifiedActor()) {
      _ = try await useCase(url: urlMock)
    }

    #expect(serviceSpy.declineUrlWithReceivedArguments?.error == .accessDenied)
  }

  @Test
  func execute_unknownActorRegistry_throwsUnknownRegistry() async {
    actorIdentityValidatorSpy.validateForThrowableError = GovernanceError.unknownRegistry

    await #expect(throws: FetchPresentationRequestUseCaseError.unknownRegistry()) {
      _ = try await useCase(url: urlMock)
    }

    #expect(serviceSpy.declineUrlWithReceivedArguments?.error == .accessDenied)
  }

  @Test
  func execute_fetchActorComplianceFails_returnsNotCompliantWithoutReason() async throws {
    nonComplianceRepositorySpy.fetchActorComplianceForThrowableError = TestingError.error

    let context = try await useCase(url: urlMock)

    #expect(context.actorCompliance == .notCompliant(nil))
  }

  @Test
  func execute_serviceInvalidUrlError_throwsInvalidUrlError() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestError.invalidRequestUrl

    await #expect(throws: FetchPresentationRequestUseCaseError.invalidUrl) {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func execute_serviceExpiredError_throwsExpiredError() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestError.expired

    await #expect(throws: FetchPresentationRequestUseCaseError.expired) {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func execute_serviceInvalidRequestError_declinesAndThrowsInvalidRequest() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestError.invalid(
      responseURL: Self.requestObjectMock.payload.responseUri,
      responseError: .invalidRequest)

    await #expect(throws: FetchPresentationRequestUseCaseError.invalidRequest("invalid_request")) {
      _ = try await useCase(url: urlMock)
    }

    #expect(
      serviceSpy.declineUrlWithReceivedArguments?.url == Self.requestObjectMock.payload.responseUri)
    #expect(serviceSpy.declineUrlWithReceivedArguments?.error == .invalidRequest)
  }

  @Test
  func execute_declineReturnsPresentationResponse_forwardsResponseWithError() async {
    let presentationResponse = PresentationResponse(redirectUri: URL(string: "https://verifier.ch"))
    serviceSpy.declineUrlWithReturnValue = presentationResponse
    serviceSpy.fetchFromThrowableError = PresentationRequestError.invalid(
      responseURL: Self.requestObjectMock.payload.responseUri,
      responseError: .invalidRequest)

    await #expect(
      throws: FetchPresentationRequestUseCaseError.invalidRequest(
        "invalid_request",
        presentationResponse: presentationResponse))
    {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func execute_declineReturnsInvalidRedirectUri_throwsValidationError() async {
    serviceSpy.declineUrlWithThrowableError = PresentationResponseValidationError.invalidRedirectUri
    serviceSpy.fetchFromThrowableError = PresentationRequestError.invalid(
      responseURL: Self.requestObjectMock.payload.responseUri,
      responseError: .invalidRequest)

    await #expect(throws: PresentationResponseValidationError.invalidRedirectUri) {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func
    execute_servicetransactionDataNotSupportedError_declinesAndThrowsTransactionDataNotSupported()
    async throws
  {
    serviceSpy.fetchFromThrowableError =
      PresentationRequestError.transactionDataNotSupported(
        responseURL: Self.requestObjectMock.payload.responseUri,
        responseError: .invalidRequest)

    await #expect(
      throws: FetchPresentationRequestUseCaseError.transactionDataNotSupported("invalid_request"))
    {
      _ = try await useCase(url: urlMock)
    }

    #expect(
      serviceSpy.declineUrlWithReceivedArguments?.url == Self.requestObjectMock.payload.responseUri)
    #expect(serviceSpy.declineUrlWithReceivedArguments?.error == .invalidRequest)
  }

  @Test
  func execute_serviceNotFoundError_throwsExpired() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestError.expired

    await #expect(throws: FetchPresentationRequestUseCaseError.expired) {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func execute_serviceNotFoundError_throwsNotFound() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestError.presentationRequestNotFound

    await #expect(throws: FetchPresentationRequestUseCaseError.notFound) {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func execute_serviceTestingError_throwsTestingError() async throws {
    serviceSpy.fetchFromThrowableError = TestingError.error

    await #expect(
      throws: FetchPresentationRequestUseCaseError.invalidRequest(
        TestingError.error.localizedDescription))
    {
      _ = try await useCase(url: urlMock)
    }
  }

  @Test
  func execute_getCompatibleCredentialsError_throwsError() async throws {
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      _ = try await useCase(url: urlMock)
    }
  }

  // MARK: Private

  private static let requestObjectMock = RequestObjectJWS.Mock.sample

  private let urlMock = URL(string: "https://example.com")!

  private let requestObjectJWSMock = RequestObjectJWS.Mock.sample
  private let compatibleCredentialsMock: [CompatibleCredential] = [CompatibleCredential.Mock.BIT]
  private let trustInformationMock = TrustInformation.Mock.trustedIdentity
  private let actorComplianceMock = ActorCompliance.notCompliant(
    LocalizedDisplay(values: ["en": "reason EN"]))
  private let legacyVerifierNamesMock = ["en": "Verifier EN"]

  private var serviceSpy: PresentationRequestServiceProtocolSpy
  private var trustInformationServiceSpy: TrustInformationServiceProtocolSpy
  private var getCompatibleCredentialsUseCaseSpy: GetCompatibleCredentialsUseCaseProtocolSpy
  private var actorIdentityValidatorSpy: ActorIdentityValidatorProtocolSpy
  private var nonComplianceRepositorySpy: NonComplianceRepositoryProtocolSpy

  private var useCase: FetchPresentationRequestUseCase
}
