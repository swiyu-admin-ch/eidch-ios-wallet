import Factory
import Spyable
import XCTest
@testable import BITAppAttestation
@testable import BITCore
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
  }

  func testCallAsFunction_withValidParameters_callsRepositorySubmitRequest() async throws {
    let caseId = "test-case-id-123"
    let authJwt = "test-auth-jwt-token"

    try await useCase(caseId: caseId, authJwt: authJwt)

    XCTAssertTrue(eIDRequestRepository.submitRequestCaseIdAuthJwtCalled)
    XCTAssertEqual(eIDRequestRepository.submitRequestCaseIdAuthJwtCallsCount, 1)
    XCTAssertEqual(eIDRequestRepository.submitRequestCaseIdAuthJwtReceivedArguments?.caseId, caseId)
    XCTAssertEqual(eIDRequestRepository.submitRequestCaseIdAuthJwtReceivedArguments?.authJwt, authJwt)
  }

  func testCallAsFunction_whenRepositoryThrowsError_propagatesError() async throws {
    let caseId = "test-case-id-123"
    let authJwt = "test-auth-jwt-token"
    eIDRequestRepository.submitRequestCaseIdAuthJwtThrowableError = TestingError.error

    do {
      try await useCase(caseId: caseId, authJwt: authJwt)
      XCTFail("Expected error to be thrown")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(eIDRequestRepository.submitRequestCaseIdAuthJwtCalled)
    }
  }

  // MARK: Private

  private var useCase: SubmitEIDRequestUseCase!
  private var eIDRequestRepository: EIDRequestRepositoryProtocolSpy!

  private func registerMocks() {
    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()
    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
