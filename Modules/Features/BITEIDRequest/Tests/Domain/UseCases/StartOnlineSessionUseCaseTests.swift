import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class StartOnlineSessionUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = StartOnlineSessionUseCase()
    createSuccessState()
  }

  func testExecute_requestCaseReadyForAVState_success() async throws {
    try await useCase.execute(for: caseId)

    XCTAssertEqual(repository.fetchRequestStatusForCallsCount, 1)
    XCTAssertEqual(repository.fetchRequestStatusForReceivedCaseId, caseId)

    XCTAssertEqual(repository.startOnlineSessionCaseIdCallsCount, 1)
    XCTAssertEqual(repository.startOnlineSessionCaseIdReceivedCaseId, caseId)
  }

  func testExecute_requestCaseInWalletPairingState_success() async throws {
    repository.fetchRequestStatusForReturnValue = mockEIDRequstStatusInWalletPairing

    try await useCase.execute(for: caseId)

    XCTAssertEqual(repository.fetchRequestStatusForCallsCount, 1)
    XCTAssertEqual(repository.fetchRequestStatusForReceivedCaseId, caseId)

    XCTAssertFalse(repository.startOnlineSessionCaseIdCalled)
  }

  func testExecute_fetchRequestCaseStatusThrowsError_throwsError() async throws {
    repository.fetchRequestStatusForThrowableError = TestingError.error

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertFalse(repository.startOnlineSessionCaseIdCalled)
    }
  }

  func testExecute_startOnlineSessionThrowsError_throwsError() async throws {
    repository.startOnlineSessionCaseIdThrowableError = TestingError.error

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let caseId = "caseId"
  private let mockEIDRequstStatusReadyForAV = EIDRequestStatus.Mock.readyForAVSample
  private let mockEIDRequstStatusInWalletPairing = EIDRequestStatus.Mock.inWalletPairingSample

  private var useCase: StartOnlineSessionUseCase!
  private var repository: EIDRequestRepositoryProtocolSpy!

  private func registerMocks() {
    repository = EIDRequestRepositoryProtocolSpy()
    Container.shared.eIDRequestRepository.register { self.repository }
  }

  private func createSuccessState() {
    repository.fetchRequestStatusForReturnValue = mockEIDRequstStatusReadyForAV
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
