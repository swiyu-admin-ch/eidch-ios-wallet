import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional

final class DeleteEIDRequestCaseUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = EIDRequestCaseRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.repository }

    useCase = DeleteEIDRequestCaseUseCase()
  }

  func testExecute_success() async throws {
    try await useCase.execute(mockCaseId)

    XCTAssertEqual(repository.deleteAllFilesForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(repository.deleteAllFilesForRequestCaseIdReceivedId, mockCaseId)
    XCTAssertEqual(repository.deleteCallsCount, 1)
    XCTAssertEqual(repository.deleteReceivedId, mockCaseId)
  }

  func testExecute_deleteFilesFails_throws() async throws {
    repository.deleteAllFilesForRequestCaseIdThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockCaseId)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertFalse(repository.deleteCalled)
    }
  }

  func testExecute_deleteRequestCaseFails_throws() async throws {
    repository.deleteThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockCaseId)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: DeleteEIDRequestCaseUseCase!
  private let mockCaseId = "caseId"
  private var repository: EIDRequestCaseRepositoryProtocolSpy!
}
