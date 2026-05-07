// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class GetCredentialActivitiesUseCaseTest: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = GetCredentialActivitiesUseCase()
    createSuccessState()
  }

  func testCallAsFunction_noLimit_returnsAll() throws {
    let activites = try useCase(for: credentialIdMock)

    XCTAssertEqual(activites, activityItemMocks)
    XCTAssertEqual(repositorySpy.getAllForLimitCallsCount, 1)
    XCTAssertEqual(repositorySpy.getAllForLimitReceivedArguments?.credentialId, credentialIdMock)
    XCTAssertEqual(repositorySpy.getAllForLimitReceivedArguments?.limit, Int.max)
  }

  func testCallAsFunction_limit_passesLimit() throws {
    let limit = 3
    let activites = try useCase(for: credentialIdMock, limit: limit)

    XCTAssertEqual(activites, activityItemMocks)
    XCTAssertEqual(repositorySpy.getAllForLimitCallsCount, 1)
    XCTAssertEqual(repositorySpy.getAllForLimitReceivedArguments?.credentialId, credentialIdMock)
    XCTAssertEqual(repositorySpy.getAllForLimitReceivedArguments?.limit, limit)
  }

  func testCallAsFunction_activityHistoryDisabled_returnsEmptyList() throws {
    repositorySpy.isActivityHistoryEnabledReturnValue = false

    let activites = try useCase(for: credentialIdMock)

    XCTAssertTrue(activites.isEmpty)
  }

  func testCallAsFunction_repositoryGetAllError_throws() throws {
    repositorySpy.getAllForLimitThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(for: credentialIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_repositoryIsActivityHistoryEnabledError_throws() throws {
    repositorySpy.isActivityHistoryEnabledThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase(for: credentialIdMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: GetCredentialActivitiesUseCase!
  private var activityItemMocks: [ActivityListItem] = [.Mock.issuance, .Mock.acceptedPresentation]
  private var credentialIdMock = UUID()
  private var repositorySpy = ActivityRepositoryProtocolSpy()

  private func registerMocks() {
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }

  private func createSuccessState() {
    repositorySpy.getAllForLimitReturnValue = activityItemMocks
    repositorySpy.isActivityHistoryEnabledReturnValue = true
  }

}
