// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import BITNetworking
import Factory
import RealmSwift
import XCTest
@testable import BITActivity
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITDataStore
@testable import BITEntities
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

  func testFetchNonCompliantActor_isNonCompliant_success() async throws {
    mockResponse(code: 200, data: nonCompliantActorsResponseDataMock)

    let result = try await repository.fetchNonCompliantActor(for: subjectDidMock)

    XCTAssertEqual(mapperSpy.mapDidCallsCount, 1)
    XCTAssertEqual(mapperSpy.mapDidReceivedDid, subjectDidMock)
    XCTAssertEqual(result?.did, nonCompliantActorsResponseMock.nonCompliantActors.first?.did)
    XCTAssertEqual(result?.reason, nonCompliantActorsResponseMock.nonCompliantActors.first?.reason)
  }

  func testFetchNonCompliantActor_isNotListed_success() async throws {
    mockResponse(code: 200, data: nonCompliantActorsResponseDataMock)
    let notListedDid = "did:example:notlisted"

    let result = try await repository.fetchNonCompliantActor(for: notListedDid)

    XCTAssertNil(result)
  }

  func testFetchNonCompliantActor_emptyList_success() async throws {
    mockResponse(code: 200, data: NonCompliantActorsResponse.Mock.emptyData)
    let notListedDid = "did:example:notlisted"

    let result = try await repository.fetchNonCompliantActor(for: notListedDid)

    XCTAssertNil(result)
  }

  func testFetchNonCompliantActor_urlMapperThrows_throws() async throws {
    mockResponse(code: 200, data: nonCompliantActorsResponseDataMock)
    mapperSpy.mapDidThrowableError = TestingError.error

    do {
      _ = try await repository.fetchNonCompliantActor(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
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
  private let nonCompliantActorsResponseMock = NonCompliantActorsResponse.Mock.default
  private let nonCompliantActorsResponseDataMock = NonCompliantActorsResponse.Mock.defaultData
  private let actorDisplayMock = ActivityActorDisplay.Mock.default
  private let nonComplianceActivityMock = NonComplianceActivity.Mock.default

  private var reportBodyGeneratorSpy: NonComplianceReportRequestBodyGeneratorProtocolSpy!
  private var proofOfPossessionGeneratorSpy: ProofOfPossessionGeneratorProtocolSpy!
  private var clientAttestationRepositorySpy: ClientAttestationRepositoryProtocolSpy!
  private var mapperSpy: TrustRegistryUrlMapperProtocolSpy!
  private var userSession: SessionSpy!
  private var userContext: LAContextProtocolSpy!
  private var actorDisplayFactorySpy: ActivityActorDisplayFactoryProtocolSpy!
  private var activityFactorySpy: NonComplianceActivityFactoryProtocolSpy!

  private func registerMocks() {
    reportBodyGeneratorSpy = NonComplianceReportRequestBodyGeneratorProtocolSpy()
    proofOfPossessionGeneratorSpy = ProofOfPossessionGeneratorProtocolSpy()
    clientAttestationRepositorySpy = ClientAttestationRepositoryProtocolSpy()
    mapperSpy = TrustRegistryUrlMapperProtocolSpy()
    actorDisplayFactorySpy = ActivityActorDisplayFactoryProtocolSpy()
    activityFactorySpy = NonComplianceActivityFactoryProtocolSpy()

    userSession = SessionSpy()
    userContext = LAContextProtocolSpy()
    userSession.isLoggedIn = true
    userSession.context = userContext

    Container.shared.configureInMemoryDataStore()
    Container.shared.nonComplianceReportRequestBodyGenerator.register { self.reportBodyGeneratorSpy }
    Container.shared.proofOfPossessionGenerator.register { self.proofOfPossessionGeneratorSpy }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepositorySpy }
    Container.shared.trustRegistryUrlMapper.register { self.mapperSpy }
    Container.shared.activityActorDisplayFactory.register { self.actorDisplayFactorySpy }
    Container.shared.nonComplianceActivityFactory.register { self.activityFactorySpy }
    Container.shared.nonComplianceBaseURL.register { self.baseURLMock }
    Container.shared.userSession.register { self.userSession }
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
