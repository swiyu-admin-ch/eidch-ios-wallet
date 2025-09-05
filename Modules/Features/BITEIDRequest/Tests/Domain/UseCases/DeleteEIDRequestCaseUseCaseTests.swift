// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

final class DeleteEIDRequestCaseUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = EIDRequestCaseRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.repository }

    useCase = DeleteEIDRequestCaseUseCase()
  }

  func testExecuteSucces() async throws {
    try await useCase.execute(mockEIDRequestCase.id)

    XCTAssertEqual(repository.deleteReceivedId, mockEIDRequestCase.id)
  }

  func testExecuteFailure() async throws {
    repository.deleteThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockEIDRequestCase.id)
      XCTFail("An error was expected")
    } catch TestingError.error {
      XCTAssertEqual(repository.deleteReceivedId, mockEIDRequestCase.id)
    }
  }

  // MARK: Private

  private var useCase: DeleteEIDRequestCaseUseCase!
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleExpired
  private var repository: EIDRequestCaseRepositoryProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional
