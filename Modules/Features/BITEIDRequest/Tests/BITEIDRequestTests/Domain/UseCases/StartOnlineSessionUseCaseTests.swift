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
  }

  func testExecute_success() async throws {
    try await useCase.execute(for: caseId)

    XCTAssertEqual(repository.startOnlineSessionCaseIdCallsCount, 1)
    XCTAssertEqual(repository.startOnlineSessionCaseIdReceivedCaseId, caseId)
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

  private var useCase: StartOnlineSessionUseCase!
  private var repository: SIDRepositoryProtocolSpy!

  private func registerMocks() {
    repository = SIDRepositoryProtocolSpy()
    Container.shared.sidRepository.register { self.repository }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
