// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import BITNetworking
import Factory
import XCTest
@testable import BITActivity
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITDataStore
@testable import BITEntities
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITNonCompliance
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - NonComplianceRepositoryTests

final class NonComplianceRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    repository = NonComplianceRepository()
    success()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  func testCreate_success() async throws {
    mockResponse(code: 200)

    try await repository.create(reportMock)

    XCTAssertEqual(reportBodyGeneratorSpy.generateFromCallsCount, 1)
    XCTAssertEqual(reportBodyGeneratorSpy.generateFromReceivedReport as? NonComplianceExcessiveDataReport, reportMock)
    XCTAssertEqual(proofOfPossessionGeneratorSpy.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.audience, baseURLMock.absoluteString)
    XCTAssertEqual(proofOfPossessionGeneratorSpy.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.challengeEndpoint, URL(target: NonComplianceEndpoint.challenge))
    XCTAssertEqual(proofOfPossessionGeneratorSpy.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.clientAttestation, clientAttestationMock)
  }

  func testCreate_bodyGeneratorError_throws() async throws {
    reportBodyGeneratorSpy.generateFromThrowableError = TestingError.error

    do {
      try await repository.create(reportMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(proofOfPossessionGeneratorSpy.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount, 0)
    }
  }

  func testCreate_generateProofOfPossessionsFails_throws() async throws {
    proofOfPossessionGeneratorSpy.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    do {
      try await repository.create(reportMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(reportBodyGeneratorSpy.generateFromCallsCount, 1)
    }
  }

  func testCreate_serverError_throwsServerError() async throws {
    mockResponse(code: 500)

    do {
      try await repository.create(reportMock)
      XCTFail("Expected error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  func testFetchActorCompliance_isNonCompliant_success() async throws {
    mockResponse(code: 200, data: NonComplianceTrustListStatementJWT.Mock.rawJWSData)

    let result = try await repository.fetchActorCompliance(for: subjectDidMock)

    XCTAssertEqual(mapperSpy.mapDidCallsCount, 1)
    XCTAssertEqual(mapperSpy.mapDidReceivedDid, subjectDidMock)
    XCTAssertEqual(result, .notCompliant(NonComplianceTrustListStatementJWT.Mock.notCompliantReason))
  }

  func testFetchActorCompliance_isNotListed_success() async throws {
    mockResponse(code: 200, data: NonComplianceTrustListStatementJWT.Mock.rawJWSData)
    let notListedDid = "did:example:notlisted"

    let result = try await repository.fetchActorCompliance(for: notListedDid)

    XCTAssertEqual(result, .compliant)
  }

  func testFetchActorCompliance_emptyList_success() async throws {
    jwsDecoderMock.jwt = emptyNonComplianceTrustListStatementMock.payload
    mockResponse(code: 200, data: NonComplianceTrustListStatementJWT.Mock.rawJWSData)
    let notListedDid = "did:example:notlisted"

    let result = try await repository.fetchActorCompliance(for: notListedDid)

    XCTAssertEqual(result, .compliant)
  }

  func testFetchActorCompliance_urlMapperThrows_throws() async throws {
    mockResponse(code: 200, data: NonComplianceTrustListStatementJWT.Mock.rawJWSData)
    mapperSpy.mapDidThrowableError = TestingError.error

    do {
      _ = try await repository.fetchActorCompliance(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(trustStatementValidatorSpy.validateForCallsCount, 0)
    }
  }

  func testFetchActorCompliance_trustStatementValidatorThrows_throws() async throws {
    mockResponse(code: 200, data: NonComplianceTrustListStatementJWT.Mock.rawJWSData)
    trustStatementValidatorSpy.validateThrowingError = TestingError.error

    do {
      _ = try await repository.fetchActorCompliance(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(trustStatementValidatorSpy.validateCallsCount, 1)
    }
  }

  func testGetActivity_success() throws {
    let activity = try CredentialActivityEntity.Mock.create()

    let fetched = try repository.getActivity(activity.id)

    XCTAssertEqual(activityFactorySpy.callAsFunctionReceivedEntity, activity)
    XCTAssertEqual(fetched, nonComplianceActivityMock)
  }

  func testGetActivity_noActivity_notFound() throws {
    XCTAssertThrowsError(try repository.getActivity(UUID())) { error in
      XCTAssertEqual(error as? NonComplianceRepositoryError, .activityNotFound)
    }
  }

  func testGetActivityActorDisplay_success() throws {
    let locale = "locale"
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(locale: locale, createParent: false)
    let activity = try CredentialActivityEntity.Mock.create(actorDisplays: [actorDisplay])

    let fetched = try repository.getActivityActorDisplay(activity.id)

    XCTAssertEqual(actorDisplayFactorySpy.callAsFunctionReceivedEntity?.locale, locale)
    XCTAssertEqual(fetched, actorDisplayMock)
  }

  func testGetActivityActorDisplay_noActivity_throwsErrors() throws {
    XCTAssertThrowsError(try repository.getActivityActorDisplay(UUID())) { error in
      XCTAssertEqual(error as? NonComplianceRepositoryError, .activityNotFound)
    }
  }

  func testGetActivityActorDisplay_noActorDisplay_returnsNil() throws {
    let activity = try CredentialActivityEntity.Mock.create()

    let fetched = try repository.getActivityActorDisplay(activity.id)

    XCTAssertNil(fetched)
  }

  // MARK: Private

  private var repository: NonComplianceRepository!

  private let reportMock = NonComplianceExcessiveDataReport.Mock.default
  private let reportBodyMock = NonComplianceExcessiveDataReportBody.Mock.default
  private let baseURLMock = URL(string: "some://url")!
  private let clientAttestationMock = ClientAttestationJWT.Mock.sample
  private let clientAttestationProofOfPossessionMock = ClientAttestationProofOfPossession.Mock.sample
  private let subjectDidMock = "did:example:verifier1"
  private let trustRegistryURLMock = URL(string: "https://example.com")
  private let actorDisplayMock = ActivityActorDisplay.Mock.default
  private let nonComplianceActivityMock = NonComplianceActivity.Mock.default
  private let nonComplianceTrustListStatementMock = NonComplianceTrustListStatementJWT.Mock.sample
  private let emptyNonComplianceTrustListStatementMock = NonComplianceTrustListStatementJWT.Mock.empty

  private var reportBodyGeneratorSpy: NonComplianceReportRequestBodyGeneratorProtocolSpy!
  private var proofOfPossessionGeneratorSpy: ProofOfPossessionGeneratorProtocolSpy!
  private var clientAttestationRepositorySpy: ClientAttestationRepositoryProtocolSpy!
  private var mapperSpy: TrustRegistryUrlMapperProtocolSpy!
  private var jwsDecoderMock: JWSDecoderMock<NonComplianceTrustListStatementJWT>!
  private var trustStatementValidatorSpy: TrustStatementValidatorProtocolSpy<NonComplianceTrustListStatementJWT>!
  private var userSession: SessionSpy!
  private var userContext: LAContextProtocolSpy!
  private var actorDisplayFactorySpy: ActivityActorDisplayFactoryProtocolSpy!
  private var activityFactorySpy: NonComplianceActivityFactoryProtocolSpy!

  private func registerMocks() {
    let reportBodyGeneratorSpy = NonComplianceReportRequestBodyGeneratorProtocolSpy()
    self.reportBodyGeneratorSpy = reportBodyGeneratorSpy
    let proofOfPossessionGeneratorSpy = ProofOfPossessionGeneratorProtocolSpy()
    self.proofOfPossessionGeneratorSpy = proofOfPossessionGeneratorSpy
    let clientAttestationRepositorySpy = ClientAttestationRepositoryProtocolSpy()
    self.clientAttestationRepositorySpy = clientAttestationRepositorySpy
    let mapperSpy = TrustRegistryUrlMapperProtocolSpy()
    self.mapperSpy = mapperSpy
    let jwsDecoderMock = JWSDecoderMock(
      jwt: nonComplianceTrustListStatementMock.payload,
      rawPayload: nonComplianceTrustListStatementMock.rawPayload,
      expectedInput: NonComplianceTrustListStatementJWT.Mock.rawJWS)
    self.jwsDecoderMock = jwsDecoderMock
    let trustStatementValidatorSpy = TrustStatementValidatorProtocolSpy<NonComplianceTrustListStatementJWT>()
    self.trustStatementValidatorSpy = trustStatementValidatorSpy
    let actorDisplayFactorySpy = ActivityActorDisplayFactoryProtocolSpy()
    self.actorDisplayFactorySpy = actorDisplayFactorySpy
    let activityFactorySpy = NonComplianceActivityFactoryProtocolSpy()
    self.activityFactorySpy = activityFactorySpy

    let userSession = SessionSpy()
    self.userSession = userSession
    userContext = LAContextProtocolSpy()
    userSession.isLoggedIn = true
    userSession.context = userContext

    Container.shared.configureInMemoryDataStore()
    Container.shared.nonComplianceReportRequestBodyGenerator.register { reportBodyGeneratorSpy }
    Container.shared.proofOfPossessionGenerator.register { proofOfPossessionGeneratorSpy }
    Container.shared.clientAttestationRepository.register { clientAttestationRepositorySpy }
    Container.shared.trustRegistryUrlMapper.register { mapperSpy }
    Container.shared.jwsDecoder.register { jwsDecoderMock }
    Container.shared.trustStatementValidator.register { trustStatementValidatorSpy }
    Container.shared.activityActorDisplayFactory.register { actorDisplayFactorySpy }
    Container.shared.nonComplianceActivityFactory.register { activityFactorySpy }
    let baseURLMock = baseURLMock
    Container.shared.nonComplianceBaseURL.register { baseURLMock }
    Container.shared.userSession.register { userSession }
  }

  private func success() {
    reportBodyGeneratorSpy.generateFromReturnValue = reportBodyMock
    proofOfPossessionGeneratorSpy.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReturnValue = clientAttestationProofOfPossessionMock
    clientAttestationRepositorySpy.getUsingReturnValue = clientAttestationMock
    mapperSpy.mapDidReturnValue = trustRegistryURLMock
    actorDisplayFactorySpy.callAsFunctionReturnValue = actorDisplayMock
    activityFactorySpy.callAsFunctionReturnValue = nonComplianceActivityMock
  }

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
