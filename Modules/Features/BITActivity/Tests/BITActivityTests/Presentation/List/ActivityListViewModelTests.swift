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

  func testFetchActivites_activities_stateIsResultWithActivities() async {
    await viewModel.fetchActivities()

    if case .result(let activities) = viewModel.state {
      XCTAssertEqual(activities.map(\.id), activityMocks.map(\.id))
    } else {
      XCTFail("Expected result state")
    }
  }

  func testFetchActivites_noActivities_stateIsResultWithoutActivities() async {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = []

    await viewModel.fetchActivities()

    if case .result(let activities) = viewModel.state {
      XCTAssertTrue(activities.isEmpty)
    } else {
      XCTFail("Expected result state")
    }
  }

  func testFetchActivites_useCaseThrowsError_stateIsError() async {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitThrowableError = TestingError.error

    await viewModel.fetchActivities()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, .error)
    } else {
      XCTFail("Expected error state")
    }
  }

  func testShowActivityDeleted_toastIsPresented() {
    XCTAssertNil(viewModel.toast)

    viewModel.showActivityDeleted()

    XCTAssertNotNil(viewModel.toast)
  }

  // MARK: Private

  private var activityMocks: [ActivityListItem] = [.Mock.issuance, .Mock.acceptedPresentation]
  private var credentialIdMock = UUID()

  private var getCredentialActivitiesUseCaseSpy: GetCredentialActivitiesUseCaseProtocolSpy!

  private var viewModel: ActivityListViewModel!

  private func registerMocks() {
    getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()
    Container.shared.getCredentialActivitiesUseCase.register { @MainActor in self.getCredentialActivitiesUseCaseSpy }
  }

  private func createSuccessState() {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = activityMocks
  }
}
