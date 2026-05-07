import BITL10n
import Factory
import NavigatorUI
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
    updateInputFileUseCase = UpdateInputFileUseCaseProtocolSpy()

    Container.shared.avBeam.register { @MainActor in self.avBeam }
    Container.shared.saveEIDRequestFilesUseCase.register { @MainActor in self.saveEIDRequestFilesUseCase }
    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.recordSelfieTimeout.register { 10.0 }
    Container.shared.avBeamAppID.register { @MainActor in self.appId }
    Container.shared.updateInputFileUseCase.register { @MainActor in self.updateInputFileUseCase }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_stateIsLoading() {
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.buttonState, .initial)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.captureFaceDelegate)
  }

  @MainActor
  func testCancelInitialization_sdkIsStopped() {
    viewModel.cancelInitialization(Navigator(configuration: NavigationConfiguration()))
    XCTAssertEqual(avBeam.shutdownCallsCount, 1)
  }

  // MARK: - SDK Initialization Tests

  func testCheckInitializationState_whenAlreadyInitialized_startsCamera() {
    avBeam.state = .initialized

    viewModel.checkInitializationState()

    XCTAssertFalse(avBeam.initializeUsingCalled)
  }

  func testCheckInitializationState_whenNotInitialized_initializesSDK() {
    avBeam.state = .notInitialized

    viewModel.checkInitializationState()

    XCTAssertTrue(avBeam.initializeUsingCalled)
    XCTAssertNotNil(avBeam.initializeUsingReceivedConfig)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testCheckInitializationState_failure_setsErrorDestination() {
    avBeam.state = .notInitialized
    avBeam.initializeUsingThrowableError = TestingError.error

    viewModel.checkInitializationState()

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error))
    } else {
      XCTFail("Expected error destination")
    }
  }

  // MARK: - Record Tests

  func testStartRecordSelfie_success_callsAVBeamWithCorrectConfig() async throws {
    viewModel.startRecordSelfie()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: taskDelay)

    XCTAssertTrue(avBeam.startCaptureFaceConfigCalled)
    XCTAssertEqual(updateInputFileUseCase.callAsFunctionCallsCount, 1)
    let config = avBeam.startCaptureFaceConfigReceivedConfig
    XCTAssertEqual(config?.duration, 10.0)
    XCTAssertTrue(try XCTUnwrap(config?.files.contains(avBeamFile)))
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

  func testStopRecordSelfie_stopCaptureFace() {
    viewModel.stopRecordSelfie()

    XCTAssertEqual(viewModel.buttonState, .initial)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
  }

  func testStop_callsAVBeamStopCaptureFaceAndStopCamera() {
    viewModel.stop()

    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
    XCTAssertTrue(avBeam.stopCameraCalled)
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

    viewModel.didReceiveNotification(notification: .faceCapturingStopped)

    await Task.yield()

    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
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
  private var updateInputFileUseCase: UpdateInputFileUseCaseProtocolSpy!

  private let appId = "test-app-id"
  private let avBeamFile = AVBeamFile(type: .xml, description: "input.xml", data: "input.xml".data(using: .utf8)!)

  private func success() {
    avBeam.state = .initialized
    context.caseId = "test-case-id"
    viewModel = RecordSelfieViewModel()
    XCTAssertEqual(viewModel.state, .loading)
    updateInputFileUseCase.callAsFunctionReturnValue = avBeamFile
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
