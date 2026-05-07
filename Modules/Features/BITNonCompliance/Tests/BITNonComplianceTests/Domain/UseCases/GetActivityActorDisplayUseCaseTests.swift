// swiftlint:disable implicitly_unwrapped_optional
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITNonCompliance
@testable import BITTestingCore

final class GetActivityActorDisplayUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = GetActivityActorDisplayUseCase()
    createSuccessState()
  }

  func testCallAsFunction_success_passesArguments() throws {
    let display = try useCase(activityIdMock)

    XCTAssertEqual(repositorySpy.getActivityActorDisplayCallsCount, 1)
    XCTAssertEqual(repositorySpy.getActivityActorDisplayReceivedId, activityIdMock)
    XCTAssertEqual(display, displayMock)
  }

  func testCallAsFunction_nil_returnsNil() throws {
    repositorySpy.getActivityActorDisplayReturnValue = nil

    let display = try useCase(activityIdMock)

    XCTAssertNil(display)
  }

  func testCallAsFunction_repositoryError_throwsError() throws {
    repositorySpy.getActivityActorDisplayThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(activityIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let activityIdMock = UUID()
  private let displayMock = ActivityActorDisplay.Mock.default

  private var repositorySpy: NonComplianceRepositoryProtocolSpy!
  private var useCase: GetActivityActorDisplayUseCase!

  private func registerMocks() {
    repositorySpy = NonComplianceRepositoryProtocolSpy()
    Container.shared.nonComplianceRepository.register { self.repositorySpy }
  }

  private func createSuccessState() {
    repositorySpy.getActivityActorDisplayReturnValue = displayMock
  }
}
