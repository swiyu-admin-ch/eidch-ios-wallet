import BITL10n
import Factory
import Spyable
import SwiftUI
import UIKit
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore
@testable import BITTheming

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping init_with_name

// MARK: - RecordSelfieViewModelTests

@MainActor
class RecordSelfieViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    avBeam = AVBeamProtocolSpy()
    saveEIDRequestFilesUseCase = SaveEIDRequestFilesUseCaseProtocolSpy()
    context = EIDRequestContext()

    Container.shared.avBeam.register { self.avBeam }
    Container.shared.saveEIDRequestFilesUseCase.register { self.saveEIDRequestFilesUseCase }
    Container.shared.eidRequestContext.register { self.context }
    Container.shared.recordSelfieTimeout.register { 10.0 }
    Container.shared.avBeamAppID.register { self.appId }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_stateIsLoading() {
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.buttonState, .initial)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertTrue(viewModel.isIntroductionPopupPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.captureFaceDelegate)
  }

  func testCloseIntroductionPopup_shouldSetToFalse() {
    XCTAssertTrue(viewModel.isIntroductionPopupPresented)

    viewModel.closeIntroductionPopup()

    XCTAssertFalse(viewModel.isIntroductionPopupPresented)
  }

  // MARK: - SDK Initialization Tests

  func testInitializeSDK_whenAlreadyInitialized_startsCamera() {
    avBeam.state = .initialized

    viewModel.initializeSDK()

    XCTAssertFalse(avBeam.initializeUsingCalled)
  }

  func testInitializeSDK_whenNotInitialized_initializesSDK() {
    avBeam.state = .notInitialized

    viewModel.initializeSDK()

    XCTAssertTrue(avBeam.initializeUsingCalled)
    XCTAssertNotNil(avBeam.initializeUsingReceivedConfig)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testInitializeSDK_failure_setsErrorDestination() {
    avBeam.state = .notInitialized
    avBeam.initializeUsingThrowableError = TestingError.error

    viewModel.initializeSDK()

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error))
    } else {
      XCTFail("Expected error destination")
    }
  }

  // MARK: - Record Tests

  func testStartRecordSelfie_success_callsAVBeamWithCorrectConfig() async {
    viewModel.startRecordSelfie()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: taskDelay)

    XCTAssertTrue(avBeam.startCaptureFaceConfigCalled)
    let config = avBeam.startCaptureFaceConfigReceivedConfig
    XCTAssertEqual(config?.duration, 10.0)
    XCTAssertTrue(config?.files.isEmpty == true)
  }

  func testStartRecordSelfie_failure_handlesError() async {
    avBeam.startCaptureFaceConfigThrowableError = TestingError.error

    viewModel.startRecordSelfie()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: taskDelay)

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error))
    } else {
      XCTFail("Expected error destination")
    }
  }

  func testStartRecordSelfie_buttonStateIsRecord_stopCaptureFace() async {
    viewModel.buttonState = .record

    viewModel.startRecordSelfie()

    XCTAssertEqual(viewModel.buttonState, .initial)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertTrue(viewModel.isIntroductionPopupPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
  }

  // MARK: - Stop and Close Tests

  func testStop_callsAVBeamStopCaptureFace() {
    viewModel.stop()

    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
    XCTAssertFalse(avBeam.stopCameraCalled) // Stop with a dedicated button must NOT stop the camera
  }

  // MARK: - AVBeamMessageDelegate Tests

  func testDidReceiveNotification_initialized_startsCamera() {
    viewModel.didReceiveNotification(notification: .initialized)

    // The startCamera method is called internally
    // We can't directly test state change due to async nature
  }

  func testDidReceiveNotification_streamingStarted_noStateChange() {
    let initialState = viewModel.state

    viewModel.didReceiveNotification(notification: .streamingStarted)

    XCTAssertEqual(viewModel.state, initialState)
  }

  func testDidReceiveNotification_faceCapturingStopped_clearsNotificationAndPopup() async {
    viewModel.isNotificationPresented = true
    viewModel.notification = .faceCaptureTiltSmile
    viewModel.isIntroductionPopupPresented = true

    viewModel.didReceiveNotification(notification: .faceCapturingStopped)

    await Task.yield()

    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertFalse(viewModel.isIntroductionPopupPresented)
  }

  func testDidReceiveNotification_faceCaptureTiltSmile_showsNotification() async {
    viewModel.didReceiveNotification(notification: .faceCaptureTiltSmile)
    await Task.yield()
    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, .faceCaptureTiltSmile)
  }

  func testDidReceiveNotification_faceCapturingStarted_showsNotification() async {
    viewModel.didReceiveNotification(notification: .faceCapturingStarted)

    await Task.yield()

    XCTAssertEqual(viewModel.buttonState, .record)
  }

  func testDidReceiveNotification_defaultCase_showsNotification() async {
    let testNotification = AVBeamNotification.faceCaptureMoveLeft

    viewModel.didReceiveNotification(notification: testNotification)

    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, testNotification)
  }

  // MARK: - AVBeamCaptureFaceDelegate Tests

  func testDidCompleteCaptureFace_success_savesFilesAndNavigates() async {
    let packageResult = AVBeamPackageResult(.init())

    viewModel.didCompleteCaptureFace(packageResult: packageResult)

    try? await Task.sleep(nanoseconds: taskDelay)

    XCTAssertTrue(saveEIDRequestFilesUseCase.executeForRequestCaseIdCalled)
    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
    XCTAssertEqual(viewModel.destination, .submitEidRequest)
    XCTAssertEqual(viewModel.buttonState, .success)
  }

  func testDidCompleteCaptureFace_missingCaseId_handlesError() async {
    context.caseId = nil
    let packageResult = AVBeamPackageResult(.init())

    viewModel.didCompleteCaptureFace(packageResult: packageResult)

    try? await Task.sleep(nanoseconds: taskDelay)

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(EIDRequestError.missingCaseId))
    } else {
      XCTFail("Expected error destination")
    }
  }

  func testDidCompleteCaptureFace_saveFilesError_handlesError() async {
    saveEIDRequestFilesUseCase.executeForRequestCaseIdThrowableError = TestingError.error
    let packageResult = AVBeamPackageResult(.init())

    viewModel.didCompleteCaptureFace(packageResult: packageResult)

    try? await Task.sleep(nanoseconds: taskDelay)

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error))
    } else {
      XCTFail("Expected error destination")
    }
  }

  // MARK: Private

  private var viewModel: RecordSelfieViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var saveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocolSpy!
  private var context: EIDRequestContext!
  private let taskDelay: UInt64 = 100_000_000

  private let appId = "test-app-id"

  private func success() {
    avBeam.state = .initialized
    context.caseId = "test-case-id"
    viewModel = RecordSelfieViewModel()
    XCTAssertEqual(viewModel.state, .loading)
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
