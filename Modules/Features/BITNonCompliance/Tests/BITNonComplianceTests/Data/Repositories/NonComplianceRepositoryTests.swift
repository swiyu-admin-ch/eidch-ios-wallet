// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITNetworking
import Factory
import XCTest
@testable import BITAppAttestation
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
    XCTAssertEqual(proofOfPossessionGeneratorSpy.generateForAudienceChallengeEndpointReceivedArguments?.audience, baseURLMock.absoluteString)
    XCTAssertEqual(proofOfPossessionGeneratorSpy.generateForAudienceChallengeEndpointReceivedArguments?.challengeEndpoint, URL(target: NonComplianceEndpoint.challenge))
  }

  func testCreate_bodyGeneratorError_throws() async throws {
    reportBodyGeneratorSpy.generateFromThrowableError = TestingError.error

    do {
      try await repository.create(reportMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(proofOfPossessionGeneratorSpy.generateForAudienceChallengeEndpointCallsCount, 0)
    }
  }

  func testCreate_generateProofOfPossessionsFails_throws() async throws {
    proofOfPossessionGeneratorSpy.generateForAudienceChallengeEndpointThrowableError = TestingError.error

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

  private var reportBodyGeneratorSpy: NonComplianceReportRequestBodyGeneratorProtocolSpy!
  private var proofOfPossessionGeneratorSpy: ProofOfPossessionGeneratorProtocolSpy!
  private var mapperSpy: TrustRegistryUrlMapperProtocolSpy!

  private func registerMocks() {
    reportBodyGeneratorSpy = NonComplianceReportRequestBodyGeneratorProtocolSpy()
    proofOfPossessionGeneratorSpy = ProofOfPossessionGeneratorProtocolSpy()
    mapperSpy = TrustRegistryUrlMapperProtocolSpy()

    Container.shared.nonComplianceReportRequestBodyGenerator.register { self.reportBodyGeneratorSpy }
    Container.shared.proofOfPossessionGenerator.register { self.proofOfPossessionGeneratorSpy }
    Container.shared.trustRegistryUrlMapper.register { self.mapperSpy }
    Container.shared.nonComplianceBaseURL.register { self.baseURLMock }
  }

  private func success() {
    reportBodyGeneratorSpy.generateFromReturnValue = reportBodyMock
    proofOfPossessionGeneratorSpy.generateForAudienceChallengeEndpointReturnValue = (clientAttestationMock, clientAttestationProofOfPossessionMock)
    mapperSpy.mapDidReturnValue = trustRegistryURLMock
  }

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
