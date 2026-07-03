import BITTestingCore
import Factory
import Testing
@testable import BITPushNotification

@MainActor
final class PushPermissionViewModelTests {

  // MARK: Lifecycle

  init() {
    let requestPermissionUseCaseSpy = RequestPushPermissionUseCaseProtocolSpy()
    let getPushPermissionStatusUseCaseSpy = GetPushPermissionStatusUseCaseProtocolSpy()

    Container.shared.requestPushPermissionUseCase.register { requestPermissionUseCaseSpy }
    Container.shared.getPushPermissionStatusUseCase.register { getPushPermissionStatusUseCaseSpy }

    self.requestPermissionUseCaseSpy = requestPermissionUseCaseSpy
    self.getPushPermissionStatusUseCaseSpy = getPushPermissionStatusUseCaseSpy

    viewModel = PushPermissionViewModel(
      onGrantedAction: {},
      onErrorAction: {})
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(viewModel.isLoading)
    #expect(viewModel.permissionStatus == .notDetermined)
  }

  @Test
  func refreshPermissionStatus_updatesStatusAndStopsLoading() async {
    getPushPermissionStatusUseCaseSpy.callAsFunctionReturnValue = .denied
    viewModel.isLoading = true

    await viewModel.refreshPermissionStatus()

    #expect(viewModel.permissionStatus == .denied)
    #expect(!viewModel.isLoading)
    #expect(getPushPermissionStatusUseCaseSpy.callAsFunctionCallsCount == 1)
  }

  @Test
  func requestPermission_withGrantedRequest_doesNotRefreshPermissionStatus() async {
    requestPermissionUseCaseSpy.callAsFunctionReturnValue = true

    await viewModel.requestPermission()

    #expect(requestPermissionUseCaseSpy.callAsFunctionCallsCount == 1)
    #expect(!getPushPermissionStatusUseCaseSpy.callAsFunctionCalled)
  }

  @Test
  func requestPermission_withDeniedRequest_updatesPermissionStatus() async {
    requestPermissionUseCaseSpy.callAsFunctionReturnValue = false
    getPushPermissionStatusUseCaseSpy.callAsFunctionReturnValue = .denied

    await viewModel.requestPermission()

    #expect(viewModel.permissionStatus == .denied)
    #expect(requestPermissionUseCaseSpy.callAsFunctionCallsCount == 1)
    #expect(getPushPermissionStatusUseCaseSpy.callAsFunctionCallsCount == 1)
  }

  @Test
  func requestPermission_withError_doesNotRefreshPermissionStatus() async {
    requestPermissionUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.requestPermission()

    #expect(requestPermissionUseCaseSpy.callAsFunctionCallsCount == 1)
    #expect(!getPushPermissionStatusUseCaseSpy.callAsFunctionCalled)
  }

  // MARK: Private

  private let viewModel: PushPermissionViewModel
  private let requestPermissionUseCaseSpy: RequestPushPermissionUseCaseProtocolSpy
  private let getPushPermissionStatusUseCaseSpy: GetPushPermissionStatusUseCaseProtocolSpy
}
