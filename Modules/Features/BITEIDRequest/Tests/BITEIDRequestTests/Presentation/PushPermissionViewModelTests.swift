import BITTestingCore
import Factory
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared

// MARK: - PushPermissionViewModelTests

@MainActor
class PushPermissionViewModelTests {

  // MARK: Lifecycle

  init() {
    let enablePushNotificationsUseCase = EnablePushNotificationsUseCaseProtocolSpy()
    let coordinator = EIDRequestFlowCoordinatorProtocolSpy()

    Container.shared.enablePushNotificationsUseCase.register { @MainActor in enablePushNotificationsUseCase }
    Container.shared.eidRequestFlowCoordinator.register { @MainActor in coordinator }

    self.enablePushNotificationsUseCase = enablePushNotificationsUseCase
    self.coordinator = coordinator

    viewModel = PushPermissionViewModel(mockRequestCase)
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(viewModel.isNavigationCloseTriggered == false)
    #expect(viewModel.destination == nil)
  }

  @Test
  func continueNavigation_withoutPush_routesToQueueInformation() async throws {
    if case .inQueue(let state) = try RequestCaseViewState(mockRequestCase) {
      coordinator.getNextDestinationAfterApplyForReturnValue = .queueInformation(state.onlineSessionStartOpenAt)

      await viewModel.continueNavigation(withPush: false)

      #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
      #expect(viewModel.destination == .queueInformation(state.onlineSessionStartOpenAt))
    }
  }

  @Test
  func continueNavigation_withPush_registersPushTokenAndRoutesToQueueInformation() async throws {
    if case .inQueue(let state) = try RequestCaseViewState(mockRequestCase) {
      coordinator.getNextDestinationAfterApplyForReturnValue = .queueInformation(state.onlineSessionStartOpenAt)

      await viewModel.continueNavigation(withPush: true)

      #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)
      #expect(enablePushNotificationsUseCase.callAsFunctionForReceivedCaseId == mockRequestCase.id)
      #expect(viewModel.destination == .queueInformation(state.onlineSessionStartOpenAt))
    }
  }

  @Test
  func continueNavigation_withoutPush_routesToLegalRepresentantConsent() async {
    let requestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    coordinator.getNextDestinationAfterApplyForReturnValue = .legalRepresentantConsent(caseId: requestCase.id)
    viewModel = PushPermissionViewModel(requestCase)

    await viewModel.continueNavigation(withPush: false)

    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
    #expect(viewModel.destination == .legalRepresentantConsent(caseId: requestCase.id))
  }

  @Test
  func continueNavigation_withoutPush_routesToWalletPairing() async {
    coordinator.getNextDestinationAfterApplyForReturnValue = .walletPairing
    viewModel = PushPermissionViewModel(EIDRequestCase.Mock.sampleAVReady)

    await viewModel.continueNavigation(withPush: false)

    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
    #expect(viewModel.destination == .walletPairing)
  }

  @Test
  func continueNavigation_withoutPush_closesForUnhandledState() async {
    viewModel = PushPermissionViewModel(EIDRequestCase.Mock.sampleWithoutState)

    await viewModel.continueNavigation(withPush: false)

    #expect(viewModel.destination == nil)
    #expect(viewModel.isNavigationCloseTriggered)
  }

  @Test
  func continueNavigation_withoutCoordinatorDestination_closesNavigation() async {
    coordinator.getNextDestinationAfterApplyForReturnValue = nil

    await viewModel.continueNavigation(withPush: false)

    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
    #expect(viewModel.destination == nil)
    #expect(viewModel.isNavigationCloseTriggered)
  }

  @Test
  func continueNavigation_withRegisterPushTokenError_presentsError() async {
    enablePushNotificationsUseCase.callAsFunctionForThrowableError = TestingError.error

    await viewModel.continueNavigation(withPush: true)

    #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)

    if case .error = viewModel.destination {
      #expect(true)
    } else {
      Issue.record("Expected error destination")
    }
  }

  // MARK: Private

  private var viewModel: PushPermissionViewModel
  private let mockRequestCase = EIDRequestCase.Mock.sampleInQueue

  private let enablePushNotificationsUseCase: EnablePushNotificationsUseCaseProtocolSpy
  private let coordinator: EIDRequestFlowCoordinatorProtocolSpy
}
