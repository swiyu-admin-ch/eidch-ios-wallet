// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import Spyable
import XCTest
@testable import BITAppAttestation
@testable import BITCore
@testable import BITEIDRequest
@testable import BITTestingCore

final class SubmitEIDRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = SubmitEIDRequestUseCase()
    createSuccessState()
  }

  func testExecute_parameters_success() async throws {
    let result = try await useCase.execute(mrz: mockPayload.mrz, hasLegalRepresentant: false)

    XCTAssertEqual(repository.submitRequestReceivedRequest?.body as? EIDRequestPayload, mockPayload)
    XCTAssertEqual(repository.fetchRequestStatusForReceivedCaseId, mockEIDRequestResponse.caseId)
    XCTAssertEqual(localRepository.createEIDRequestCaseReceivedEIDRequestCase?.id, mockEIDRequestResponse.caseId)
    XCTAssertNotNil(localRepository.createEIDRequestCaseReceivedEIDRequestCase?.state)
    XCTAssertEqual(result, mockEIDRequestCase)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceReceivedArguments?.body as? EIDRequestPayload, mockPayload)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceReceivedArguments?.challenge, mockChallenge)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceReceivedArguments?.audience, mockSidUrl.absoluteString)
  }

  func testExecute_count_success() async throws {
    _ = try await useCase.execute(mrz: mockPayload.mrz, hasLegalRepresentant: false)

    XCTAssertEqual(repository.submitRequestCallsCount, 1)
    XCTAssertEqual(repository.fetchRequestStatusForCallsCount, 1)
    XCTAssertEqual(localRepository.createEIDRequestCaseCallsCount, 1)
    XCTAssertEqual(generateClientAttestedRequestUseCase.executeForChallengeAudienceCallsCount, 1)
    XCTAssertEqual(repository.fetchChallengeCallsCount, 1)
  }

  func testExecute_fetchChallengeFails_throwsError() async throws {
    repository.fetchChallengeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mrz: mockPayload.mrz, hasLegalRepresentant: false)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_submitRequestFails_throwsError() async throws {
    repository.submitRequestThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mrz: mockPayload.mrz, hasLegalRepresentant: false)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchRequestStatusThrowsError_returnsNil() async throws {
    repository.fetchRequestStatusForThrowableError = TestingError.error

    let result = try await useCase.execute(mrz: mockPayload.mrz, hasLegalRepresentant: false)

    XCTAssertEqual(result.id, mockEIDRequestResponse.caseId)
    XCTAssertEqual(result.lastName, mockEIDRequestResponse.lastName)
    XCTAssertEqual(result.firstName, mockEIDRequestResponse.firstName)
    XCTAssertEqual(result.documentNumber, mockEIDRequestResponse.identityNumber)
  }

  func testExecute_saveRequestCase_throwsError() async throws {
    localRepository.createEIDRequestCaseThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mrz: mockPayload.mrz, hasLegalRepresentant: false)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: SubmitEIDRequestUseCase!

  private let mockPayload = MRZData.Mock.array.first!.payload
  private let mockEIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockEIDRequestStatus: EIDRequestStatus = .Mock.inQueueSample
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleWithoutState
  private let mockEIDRequestCaseWithoutState: EIDRequestCase = .Mock.sampleWithoutState
  private var mockClientAttestedRequest: ClientAttestedRequest!
  private var mockChallenge = "mock_challenge"
  private var mockSidUrl = URL(string: "mock_sid_url")!

  private var repository: EIDRequestRepositoryProtocolSpy!
  private var localRepository: LocalEIDRequestRepositoryProtocolSpy!
  private var generateClientAttestedRequestUseCase: GenerateClientAttestedRequestUseCaseProtocolSpy!

  private func registerMocks() {
    repository = EIDRequestRepositoryProtocolSpy()
    localRepository = LocalEIDRequestRepositoryProtocolSpy()
    generateClientAttestedRequestUseCase = GenerateClientAttestedRequestUseCaseProtocolSpy()
    mockClientAttestedRequest = ClientAttestedRequest(
      body: mockPayload,
      header: ClientAttestedRequest.Header(clientAttestation: "clientAttestation", clientAttestationPoP: "clientAttestationPoP"))

    Container.shared.eIDRequestRepository.register { self.repository }
    Container.shared.localEIDRequestRepository.register { self.localRepository }
    Container.shared.generateClientAttestedRequestUseCase.register { self.generateClientAttestedRequestUseCase }
    Container.shared.sidUrl.register { self.mockSidUrl }
  }

  private func createSuccessState() {
    repository.submitRequestReturnValue = mockEIDRequestResponse
    repository.fetchRequestStatusForReturnValue = mockEIDRequestStatus
    localRepository.createEIDRequestCaseReturnValue = mockEIDRequestCase
    generateClientAttestedRequestUseCase.executeForChallengeAudienceReturnValue = mockClientAttestedRequest
    repository.fetchChallengeReturnValue = mockChallenge
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
