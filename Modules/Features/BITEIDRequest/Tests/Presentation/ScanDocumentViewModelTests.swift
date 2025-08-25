// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import SwiftUI
import UIKit
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// MARK: - ScanDocumentViewModelTests

@MainActor
class ScanDocumentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    router.context.identityType = .identityCard
    avBeam = AVBeamProtocolSpy()
    submitEIDRequestUseCase = SubmitEIDRequestUseCaseProtocolSpy()

    Container.shared.avBeam.register { self.avBeam }
    Container.shared.submitEIDRequestUseCase.register { self.submitEIDRequestUseCase }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_sdkNotInitialized_stateIsInitializing() {
    avBeam.state = .notInitialized

    viewModel = ScanDocumentViewModel(router: router)

    XCTAssertEqual(viewModel.state, .sdkInitializing)
    XCTAssertEqual(viewModel.scanningState, .recto)
    XCTAssertEqual(viewModel.introductionPopupState, .recto)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.scanDocumentDelegate)
  }

  // MARK: - State Management Tests

  func testScanningState_whenChanged_updatesIntroductionPopupState() {
    viewModel.scanningState = .verso

    XCTAssertEqual(viewModel.introductionPopupState, .verso)
  }

  func testTitle_returnsCorrectTitle() {
    XCTAssertEqual(viewModel.title, "Recto")

    viewModel.scanningState = .verso
    XCTAssertEqual(viewModel.title, "Verso")
  }

  // MARK: - SDK Initialization Tests

  func testInitializeSDK_success_doesNotChangeState() async {
    await viewModel.initializeSDK()

    XCTAssertTrue(avBeam.initializeUsingCalled)
    XCTAssertNotNil(avBeam.initializeUsingReceivedConfig)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testInitializeSDK_failure_setsErrorState() async {
    avBeam.initializeUsingThrowableError = TestingError.error

    await viewModel.initializeSDK()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, TestingError.error)
    } else {
      XCTFail("Expected error state")
    }
  }

  // MARK: - Camera Tests

  func testStartCamera_success_callsAVBeam() async {
    await viewModel.startCamera()
    await Task.yield()

    XCTAssertTrue(avBeam.startCameraCalled)
  }

  func testStartCamera_failure_setsErrorState() async {
    avBeam.startCameraThrowableError = TestingError.error

    await viewModel.startCamera()
    await Task.yield()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, TestingError.error)
    } else {
      XCTFail("Expected error state")
    }
  }

  // MARK: - Scan Tests

  func testStartScan_success_callsAVBeamWithCorrectConfig() async {
    await viewModel.startScan(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    await Task.yield()

    XCTAssertTrue(avBeam.startScanDocumentConfigCalled)
    let config = avBeam.startScanDocumentConfigReceivedConfig
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.timeout, 15)

    XCTAssertEqual(config?.scanFrame.width, 0)
    XCTAssertEqual(config?.scanFrame.height, 0)
    XCTAssertEqual(config?.scanFrame.origin.y, 0)
    XCTAssertEqual(config?.scanFrame.origin.x, 0)
  }

  func testStartScan_failure_setsErrorState() async {
    avBeam.startScanDocumentConfigThrowableError = TestingError.error

    await viewModel.startScan(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    await Task.yield()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, TestingError.error)
    } else {
      XCTFail("Expected error state")
    }
  }

  // MARK: - Stop and Close Tests

  func testStop_callsAVBeamMethods() {
    viewModel.stop()

    XCTAssertTrue(avBeam.stopScanDocumentCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
  }

  func testClose_callsStopAndRouter() {
    viewModel.close()

    XCTAssertTrue(avBeam.stopScanDocumentCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: - AVBeamMessageDelegate Tests

  func testDidReceiveNotification_initialized_setsReadyState() {
    viewModel.didReceiveNotification(notification: .initialized)

    XCTAssertEqual(viewModel.state, .ready)
  }

  func testDidReceiveNotification_idDocMatched_noStateChange() {
    let initialState = viewModel.state

    viewModel.didReceiveNotification(notification: .idDocMatched)

    XCTAssertEqual(viewModel.state, initialState)
  }

  func testDidReceiveNotification_idDocNotMatched_noStateChange() {
    let initialState = viewModel.state

    viewModel.didReceiveNotification(notification: .idDocNotMatched)

    XCTAssertEqual(viewModel.state, initialState)
  }

  func testDidReceiveNotification_idDetectionDone_hidesNotificationAndPopup() async {
    viewModel.isNotificationPresented = true
    viewModel.notification = .idDocMatched
    viewModel.introductionPopupState = .recto

    viewModel.didReceiveNotification(notification: .idDetectionDone)

    await Task.yield()

    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNil(viewModel.introductionPopupState)
  }

  func testDidReceiveNotification_idRecognitionStopped_hidesNotification() async {
    viewModel.isNotificationPresented = true
    viewModel.notification = .idDocMatched

    viewModel.didReceiveNotification(notification: .idRecognitionStopped)

    await Task.yield()

    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
  }

  func testDidReceiveNotification_idNeedSecondPageForMatching_changesScanningState() async {
    viewModel.didReceiveNotification(notification: .idNeedSecondPageForMatching)

    await Task.yield()

    XCTAssertEqual(viewModel.scanningState, .verso)
    XCTAssertEqual(viewModel.introductionPopupState, .verso)
  }

  func testDidReceiveNotification_otherNotifications_showsNotification() async {
    let testNotification = AVBeamNotification.dataDecrypted

    viewModel.didReceiveNotification(notification: testNotification)

    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, testNotification)
  }

  // MARK: - ScanningState Tests

  func testScanningStateEquatable() {
    XCTAssertEqual(ScanDocumentViewModel.ScanningState.recto, .recto)
    XCTAssertEqual(ScanDocumentViewModel.ScanningState.verso, .verso)
    XCTAssertNotEqual(ScanDocumentViewModel.ScanningState.recto, .verso)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: ScanDocumentViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocolSpy!

  private let appId = "appID"

  // MARK: - Initialization Tests

  private func success() {
    avBeam.state = .initialized
    Container.shared.avBeamAppID.register { self.appId }
    viewModel = ScanDocumentViewModel(router: router)
    XCTAssertEqual(viewModel.state, .ready)
  }

}

// MARK: - ScanDocumentViewModel.StateView + Equatable

extension ScanDocumentViewModel.StateView: Equatable {
  public static func == (lhs: ScanDocumentViewModel.StateView, rhs: ScanDocumentViewModel.StateView) -> Bool {
    switch (lhs, rhs) {
    case (.sdkInitializing, .sdkInitializing):
      true
    case (.ready, .ready):
      true
    case (.error(let lhsError), .error(let rhsError)):
      lhsError.localizedDescription == rhsError.localizedDescription
    default:
      false
    }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
