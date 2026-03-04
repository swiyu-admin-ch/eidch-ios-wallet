// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class IsActivityHistoryEnabledUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = IsActivityHistoryEnabledUseCase()
    createSuccessState()
  }

  func testCallAsFunction_enabled_returnsTrue() throws {
    let result = try useCase()

    XCTAssertTrue(result)
    XCTAssertEqual(repositorySpy.isActivityHistoryEnabledCallsCount, 1)
  }

  func testCallAsFunction_disabled_returnsFalse() throws {
    repositorySpy.isActivityHistoryEnabledReturnValue = false

    let result = try useCase()

    XCTAssertFalse(result)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.isActivityHistoryEnabledThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var repositorySpy: ActivityRepositoryProtocolSpy!

  private var useCase: IsActivityHistoryEnabledUseCase!

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }

  private func createSuccessState() {
    repositorySpy.isActivityHistoryEnabledReturnValue = true
  }
}
