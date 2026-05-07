import Factory
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class SubmitEIDRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = SubmitEIDRequestUseCase()
    createSuccessState()
  }

  func testCallAsFunction_withValidParameters_callsRepositorySubmitRequest() async throws {
    try await useCase(caseId: mockCaseId, authJwt: mockJwt)

    XCTAssertTrue(eIDRequestRepository.submitRequestCaseIdAuthJwtCalled)
    XCTAssertEqual(eIDRequestRepository.submitRequestCaseIdAuthJwtCallsCount, 1)
    XCTAssertEqual(eIDRequestRepository.submitRequestCaseIdAuthJwtReceivedArguments?.caseId, mockCaseId)
    XCTAssertEqual(eIDRequestRepository.submitRequestCaseIdAuthJwtReceivedArguments?.authJwt, mockJwt)
    XCTAssertEqual(eIDRequestCaseRepository.getIdCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.getIdReceivedId, mockCaseId)
    XCTAssertEqual(eIDRequestCaseRepository.updateCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.filesSubmitted, true)
  }

  func testCallAsFunction_whenRepositoryThrowsError_propagatesError() async throws {
    eIDRequestRepository.submitRequestCaseIdAuthJwtThrowableError = TestingError.error

    do {
      try await useCase(caseId: mockCaseId, authJwt: mockJwt)
      XCTFail("Expected error to be thrown")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(eIDRequestRepository.submitRequestCaseIdAuthJwtCalled)
    }
  }

  func testCallAsFunction_whenGetRequestCaseThrowsError_doesNotThrowsError() async throws {
    eIDRequestCaseRepository.getIdThrowableError = TestingError.error

    try await useCase(caseId: mockCaseId, authJwt: mockJwt)

    XCTAssertTrue(eIDRequestRepository.submitRequestCaseIdAuthJwtCalled)
    XCTAssertEqual(eIDRequestCaseRepository.getIdReceivedId, mockCaseId)
    XCTAssertEqual(eIDRequestCaseRepository.updateCallsCount, 0)
  }

  func testCallAsFunction_whenUpdateRequestCaseThrowsError_doesNotThrowsError() async throws {
    eIDRequestCaseRepository.updateThrowableError = TestingError.error

    try await useCase(caseId: mockCaseId, authJwt: mockJwt)

    XCTAssertTrue(eIDRequestRepository.submitRequestCaseIdAuthJwtCalled)
    XCTAssertEqual(eIDRequestCaseRepository.getIdReceivedId, mockCaseId)
    XCTAssertEqual(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.filesSubmitted, true)
  }

  // MARK: Private

  private let mockJwt = "mockJwt"
  private let mockCaseId = "mockCaseId"
  private let mockRequestCase = EIDRequestCase.Mock.sampleAutoVerification

  private var useCase: SubmitEIDRequestUseCase!
  private var eIDRequestRepository: EIDRequestRepositoryProtocolSpy!
  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!

  private func registerMocks() {
    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }
    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
  }

  private func createSuccessState() {
    eIDRequestCaseRepository.getIdReturnValue = mockRequestCase
    eIDRequestCaseRepository.updateReturnValue = mockRequestCase
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
