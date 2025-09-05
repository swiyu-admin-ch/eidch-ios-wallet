import Factory
import Foundation
import XCTest
@testable import BITInvitation

final class CameraPermissionViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  func testWithInitialData() {
    let viewModel = CameraPermissionViewModel(initialState: .notDetermined, router: mockRouter)

    XCTAssertFalse(viewModel.primary.isEmpty)
    XCTAssertFalse(viewModel.secondary.isEmpty)
    XCTAssertFalse(viewModel.buttonText.isEmpty)
    XCTAssertFalse(mockRouter.didCallCamera)
  }

  @MainActor
  func testHappyPath() async {
    let viewModel = CameraPermissionViewModel(initialState: .notDetermined, router: mockRouter)

    await viewModel.allowCamera()

    XCTAssertTrue(mockRouter.didCallCamera)
  }

  @MainActor
  func testInitShortcut() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    XCTAssertFalse(mockRouter.didCallCamera)
    XCTAssertFalse(viewModel.primary.isEmpty)
    XCTAssertFalse(viewModel.secondary.isEmpty)
    XCTAssertFalse(viewModel.buttonText.isEmpty)
  }

  @MainActor
  func testButtonAction_PermissionStatusNotDetermined_assertCallCamera() async {
    let viewModel = CameraPermissionViewModel(initialState: .authorized, router: mockRouter)

    viewModel.buttonAction()

    XCTAssertTrue(mockRouter.didCallCamera)
  }

  @MainActor
  func testButtonAction_PermissionStatusDetermined_assertCallSettings() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    viewModel.buttonAction()

    XCTAssertTrue(mockRouter.didCallExternalSettings)
  }

  @MainActor
  func testAllowCamera() async {
    let viewModel = CameraPermissionViewModel(initialState: .authorized, router: mockRouter)

    let expectationPresented = expectation(forNotification: .permissionAlertPresented, object: nil)
    let expectationFinished = expectation(forNotification: .permissionAlertFinished, object: nil)

    await viewModel.allowCamera()

    await fulfillment(of: [expectationPresented, expectationFinished], timeout: 2)
    XCTAssertTrue(mockRouter.didCallCamera)
  }

  @MainActor
  func testOpenSettings() async {
    let viewModel = CameraPermissionViewModel(initialState: .denied, router: mockRouter)

    viewModel.openSettings()

    XCTAssertTrue(mockRouter.didCallExternalSettings)
  }

  // MARK: Private

  private var mockRouter = InvitationRouterMock()

}
