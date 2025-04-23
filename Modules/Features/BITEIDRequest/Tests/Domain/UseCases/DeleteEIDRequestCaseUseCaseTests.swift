// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

final class DeleteEIDRequestCaseUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = LocalEIDRequestRepositoryProtocolSpy()

    Container.shared.localEIDRequestRepository.register { self.repository }

    useCase = DeleteEIDRequestCaseUseCase()
  }

  func testExecuteSucces() async throws {
    try await useCase.execute(mockEIDRequestCase)

    XCTAssertEqual(repository.deleteReceivedEIDRequestCase, mockEIDRequestCase)
  }

  func testExecuteFailure() async throws {
    repository.deleteThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockEIDRequestCase)
      XCTFail("An error was expected")
    } catch TestingError.error {
      XCTAssertEqual(repository.deleteReceivedEIDRequestCase, mockEIDRequestCase)
    }
  }

  // MARK: Private

  private var useCase: DeleteEIDRequestCaseUseCase!
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleExpired
  private var repository: LocalEIDRequestRepositoryProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional
