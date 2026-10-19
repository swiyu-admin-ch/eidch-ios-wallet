import Factory
import Foundation
import Testing
@testable import BITActivity
@testable import BITTestingCore

@MainActor
struct ActivityListViewModelTests {

  // MARK: Lifecycle

  init() {
    let getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = activityMocks
    self.getCredentialActivitiesUseCaseSpy = getCredentialActivitiesUseCaseSpy

    Container.shared.getCredentialActivitiesUseCase.register { @MainActor in getCredentialActivitiesUseCaseSpy }

    viewModel = ActivityListViewModel(credentialIdMock)
  }

  // MARK: Internal

  @Test
  func fetchActivites_activities_stateIsResultWithActivities() async {
    await viewModel.fetchActivities()

    if case .result(let activities) = viewModel.state {
      #expect(activities.map(\.id) == activityMocks.map(\.id))
    } else {
      Issue.record("Expected result state")
    }
  }

  @Test
  func fetchActivites_noActivities_stateIsResultWithoutActivities() async {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = []

    await viewModel.fetchActivities()

    if case .result(let activities) = viewModel.state {
      #expect(activities.isEmpty)
    } else {
      Issue.record("Expected result state")
    }
  }

  @Test
  func fetchActivites_useCaseThrowsError_stateIsError() async {
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitThrowableError = TestingError.error

    await viewModel.fetchActivities()

    if case .error(let error) = viewModel.state {
      #expect(error as? TestingError == .error)
    } else {
      Issue.record("Expected error state")
    }
  }

  @Test
  func showActivityDeleted_toastIsPresented() {
    #expect(viewModel.toast == nil)

    viewModel.showActivityDeleted()

    #expect(viewModel.toast != nil)
  }

  // MARK: Private

  private let activityMocks: [ActivityListItem] = [.Mock.issuance, .Mock.acceptedPresentation]
  private let credentialIdMock = UUID()

  private let getCredentialActivitiesUseCaseSpy: GetCredentialActivitiesUseCaseProtocolSpy
  private let viewModel: ActivityListViewModel
}
