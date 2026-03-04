// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class SetActivityHistoryEnabledUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = SetActivityHistoryEnabledUseCase()
  }

  func testCallAsFunction_enabled_argumentsPassed() throws {
    let isEnabled = true

    try useCase(isEnabled)

    XCTAssertEqual(repositorySpy.setActivityHistoryEnabledCallsCount, 1)
    XCTAssertEqual(repositorySpy.setActivityHistoryEnabledReceivedIsEnabled, isEnabled)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.setActivityHistoryEnabledThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(true)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var repositorySpy: ActivityRepositoryProtocolSpy!

  private var useCase: SetActivityHistoryEnabledUseCase!

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }
}
