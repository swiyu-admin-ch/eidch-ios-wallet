// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITTestingCore

@MainActor
final class ActivityListViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    viewModel = ActivityListViewModel(credentialIdMock)
  }

  func testFetchActivites_activities_stateIsResultWithActivities() async throws {
    await viewModel.fetchActivities()

    if case .result(let activities) = viewModel.state {
      XCTAssertEqual(activities.map(\.activity), activityMocks)
    } else {
      XCTFail("Expected result state")
    }
  }

  func testFetchActivites_noActivities_stateIsResultWithoutActivities() async throws {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = []

    await viewModel.fetchActivities()

    if case .result(let activities) = viewModel.state {
      XCTAssertTrue(activities.isEmpty)
    } else {
      XCTFail("Expected result state")
    }
  }

  func testFetchActivites_useCaseThrowsError_stateIsError() async throws {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitThrowableError = TestingError.error

    await viewModel.fetchActivities()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, .error)
    } else {
      XCTFail("Expected error state")
    }
  }

  func testShowActivityDeleted_toastIsPresented() async throws {
    XCTAssertNil(viewModel.toastMessage)
    XCTAssertFalse(viewModel.isToastPresented)

    viewModel.showActivityDeleted()

    XCTAssertNotNil(viewModel.toastMessage)
    XCTAssertTrue(viewModel.isToastPresented)
  }

  func testClearToast_toastIsHidden() async throws {
    viewModel.showActivityDeleted()
    XCTAssertNotNil(viewModel.toastMessage)
    XCTAssertTrue(viewModel.isToastPresented)

    viewModel.clearToast()

    XCTAssertNil(viewModel.toastMessage)
    XCTAssertFalse(viewModel.isToastPresented)
  }

  // MARK: Private

  private var activityMocks: [Activity] = [.Mock.issueTrusted, .Mock.presentationAcceptedTrusted]
  private var credentialIdMock = UUID()

  private var getCredentialActivitiesUseCaseSpy: GetCredentialActivitiesUseCaseProtocolSpy!

  private var viewModel: ActivityListViewModel!

  private func registerMocks() {
    getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()
    Container.shared.getCredentialActivitiesUseCase.register { self.getCredentialActivitiesUseCaseSpy }
  }

  private func createSuccessState() {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = activityMocks
  }
}
