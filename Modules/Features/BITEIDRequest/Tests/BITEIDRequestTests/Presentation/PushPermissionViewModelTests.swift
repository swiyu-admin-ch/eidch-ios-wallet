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
    let coordinator = PushPermissionCoordinatorMock()

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
    await viewModel.continueNavigation(withPush: false)

    if case .inQueue(let state) = try RequestCaseViewState(mockRequestCase) {
      #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
      #expect(viewModel.destination == .queueInformation(state.onlineSessionStartOpenAt))
    }
  }

  @Test
  func continueNavigation_withPush_registersPushTokenAndRoutesToQueueInformation() async throws {
    await viewModel.continueNavigation(withPush: true)

    if case .inQueue(let state) = try RequestCaseViewState(mockRequestCase) {
      #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)
      #expect(enablePushNotificationsUseCase.callAsFunctionForReceivedCaseId == mockRequestCase.id)
      #expect(viewModel.destination == .queueInformation(state.onlineSessionStartOpenAt))
    }
  }

  @Test
  func continueNavigation_withoutPush_routesToLegalRepresentantConsent() async {
    let requestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    viewModel = PushPermissionViewModel(requestCase)

    await viewModel.continueNavigation(withPush: false)

    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
    #expect(viewModel.destination == .legalRepresentantConsent(caseId: requestCase.id))
  }

  @Test
  func continueNavigation_withoutPush_routesToWalletPairing() async {
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
  func continueNavigation_withCoordinatorError_closesNavigation() async {
    coordinator.throwableError = TestingError.error

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
  private let coordinator: PushPermissionCoordinatorMock

}

// MARK: - PushPermissionCoordinatorMock

@MainActor
private final class PushPermissionCoordinatorMock: EIDRequestFlowCoordinatorProtocol {
  var throwableError: Error?

  func getNextDestination(for requestCase: EIDRequestCase) async throws -> EIDRequestDestinations? {
    try getNextDestinationAfterApply(for: requestCase)
  }

  func getNextDestinationAfterApply(for requestCase: EIDRequestCase) throws -> EIDRequestDestinations? {
    if let throwableError {
      throw throwableError
    }

    let viewState = try RequestCaseViewState(requestCase)

    if !viewState.isLegalRepresentantConsentVerified {
      return .legalRepresentantConsent(caseId: requestCase.id)
    }

    switch viewState {
    case .inQueue(let state):
      return .queueInformation(state.onlineSessionStartOpenAt)
    case .readyForOnlineSession:
      return .walletPairing
    default:
      return nil
    }
  }

  func cleanup() {}
}
