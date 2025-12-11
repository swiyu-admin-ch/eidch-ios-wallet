// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class ActivityServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    service = ActivityService()
    setupSuccessState()
  }

  func testCreate_argumentsPassed() throws {
    try service.create(activityMock, credentialId: credentialIdMock)

    XCTAssertEqual(repositorySpy.createCredentialIdReceivedArguments?.activity, activityMock)
    XCTAssertEqual(repositorySpy.createCredentialIdReceivedArguments?.credentialId, credentialIdMock)
  }

  func testCreate_repositoryThrowsError_throwsError() throws {
    repositorySpy.createCredentialIdThrowableError = TestingError.error

    XCTAssertThrowsError(try service.create(activityMock, credentialId: credentialIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let credentialIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a1")!
  private let activityMock = Activity.Mock.issueTrusted

  private var repositorySpy: ActivityRepositoryProtocolSpy!

  private var service: ActivityService!

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()

    Container.shared.activityRepository.register { self.repositorySpy }
  }

  private func setupSuccessState() {
    repositorySpy.createCredentialIdReturnValue = activityMock
  }
}
