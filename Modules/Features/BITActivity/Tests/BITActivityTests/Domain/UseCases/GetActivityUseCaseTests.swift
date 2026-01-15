// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class GetActivityUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = GetActivityUseCase()
    createSuccessState()
  }

  func testCallAsFunction_success_passesArguments() throws {
    let activity = try useCase(activityIdMock)

    XCTAssertEqual(repositorySpy.getCallsCount, 1)
    XCTAssertEqual(repositorySpy.getReceivedId, activityIdMock)
    XCTAssertEqual(activity, activityMock)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.getThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(activityIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var activityIdMock = UUID()

  private var repositorySpy: ActivityRepositoryProtocolSpy!
  private var useCase: GetActivityUseCase!
  private let activityMock = Activity.Mock.issueTrusted

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }

  private func createSuccessState() {
    repositorySpy.getReturnValue = activityMock
  }
}
