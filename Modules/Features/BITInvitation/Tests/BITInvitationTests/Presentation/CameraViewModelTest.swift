import AVFoundation
import Testing
@testable import BITInvitation

@MainActor
@Suite
struct CameraViewModelTest {

  // MARK: Lifecycle

  init() {
    cameraManager = MockCameraManager()
    viewModel = CameraViewModel()
    viewModel.cameraManager = cameraManager
  }

  // MARK: Internal

  @Test(
    arguments: [
      AVAuthorizationStatus.notDetermined,
      AVAuthorizationStatus.restricted,
      AVAuthorizationStatus.denied,
    ])
  func onCameraPermissionChange_whenNotGranted(permission: AVAuthorizationStatus) async {
    await viewModel.onCameraPermissionChange(permission)

    #expect(cameraManager.startCallCount == 0)
    #expect(cameraManager.configureCallCount == 0)
    #expect(viewModel.isCameraReady == false)
  }

  @Test
  func onCameraPermissionChange_whenGranted() async {
    await viewModel.onCameraPermissionChange(.authorized)

    #expect(cameraManager.startCallCount == 1)
    #expect(cameraManager.configureCallCount == 1)
    #expect(viewModel.isCameraReady == true)
  }

  // MARK: Private

  private let viewModel: CameraViewModel
  private let cameraManager: MockCameraManager
}
