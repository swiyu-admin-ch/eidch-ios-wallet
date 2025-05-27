import XCTest
@testable import BITEIDRequest

final class CameraPermissionViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  func testWithInitialData() {
    let viewModel = CameraPermissionViewModel(initialState: .notDetermined, router: mockRouter)

    XCTAssertFalse(viewModel.primary.isEmpty)
    XCTAssertFalse(viewModel.secondary.isEmpty)
    XCTAssertFalse(viewModel.buttonText.isEmpty)
    XCTAssertFalse(mockRouter.mrzScannerCalled)
  }

  @MainActor
  func testHappyPath() async {
    let viewModel = CameraPermissionViewModel(initialState: .notDetermined, router: mockRouter)

    await viewModel.allowCamera()

    XCTAssertTrue(mockRouter.mrzScannerCalled)
  }

  @MainActor
  func testInitShortcut() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    XCTAssertFalse(mockRouter.mrzScannerCalled)
    XCTAssertFalse(viewModel.primary.isEmpty)
    XCTAssertFalse(viewModel.secondary.isEmpty)
    XCTAssertFalse(viewModel.buttonText.isEmpty)
  }

  @MainActor
  func testButtonActuityNotDetermined() async {
    let viewModel = CameraPermissionViewModel(initialState: .authorized, router: mockRouter)

    viewModel.buttonAction()

    XCTAssertTrue(mockRouter.mrzScannerCalled)
  }

  @MainActor
  func testButtonActuityDenied() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    viewModel.buttonAction()

    XCTAssertTrue(mockRouter.settingsCalled)
  }

  @MainActor
  func testAllowCamera() async {
    let viewModel = CameraPermissionViewModel(initialState: .authorized, router: mockRouter)

    let expectationPresented = expectation(forNotification: .permissionAlertPresented, object: nil)
    let expectationFinished = expectation(forNotification: .permissionAlertFinished, object: nil)

    await viewModel.allowCamera()

    await fulfillment(of: [expectationPresented, expectationFinished], timeout: 2)
    XCTAssertTrue(mockRouter.mrzScannerCalled)
  }

  @MainActor
  func testOpenSettings() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    viewModel.openSettings()

    XCTAssertTrue(mockRouter.settingsCalled)
  }

  @MainActor
  func testClose() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    viewModel.close()

    XCTAssertTrue(mockRouter.closeCalled)
  }

  // MARK: Private

  private var mockRouter = MockEIDRequestRouter()

}
