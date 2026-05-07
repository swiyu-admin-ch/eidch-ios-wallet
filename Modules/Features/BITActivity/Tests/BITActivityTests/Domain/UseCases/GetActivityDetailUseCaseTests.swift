// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class GetActivityDetailUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = GetActivityDetailUseCase()
    createSuccessState()
  }

  func testCallAsFunction_success_returnsActivityAndPassesArguments() throws {
    let activity = try useCase(activityIdMock)

    XCTAssertEqual(activity, activityMock)

    XCTAssertEqual(repositorySpy.getDetailCallsCount, 1)
    XCTAssertEqual(repositorySpy.getDetailReceivedId, activityIdMock)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.getDetailThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(activityIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var activityIdMock = UUID()

  private var repositorySpy: ActivityRepositoryProtocolSpy!
  private var useCase: GetActivityDetailUseCase!
  private let activityMock = ActivityDetail.Mock.trustedIssuance

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }

  private func createSuccessState() {
    repositorySpy.getDetailReturnValue = activityMock
  }
}
