// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class DeleteActivityUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = DeleteActivityUseCase()
  }

  func testCallAsFunction_success_passesArguments() throws {
    try useCase(activityIdMock)

    XCTAssertEqual(repositorySpy.deleteCallsCount, 1)
    XCTAssertEqual(repositorySpy.deleteReceivedId, activityIdMock)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.deleteThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(activityIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var activityIdMock = UUID()

  private var repositorySpy: ActivityRepositoryProtocolSpy!

  private var useCase: DeleteActivityUseCase!

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }
}
