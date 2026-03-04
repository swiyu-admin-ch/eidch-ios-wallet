// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class DeleteAllActivityUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = DeleteAllActivitiesUseCase()
  }

  func testCallAsFunction_success_callsCount() throws {
    try useCase()

    XCTAssertEqual(repositorySpy.deleteAllCallsCount, 1)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.deleteAllThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var repositorySpy: ActivityRepositoryProtocolSpy!

  private var useCase: DeleteAllActivitiesUseCase!

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }
}
