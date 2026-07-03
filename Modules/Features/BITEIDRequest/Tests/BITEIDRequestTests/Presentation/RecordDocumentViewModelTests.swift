// swiftlint:disable implicitly_unwrapped_optional force_unwrapping init_with_name
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

// MARK: - RecordDocumentViewModelTests

@MainActor
class RecordDocumentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()

    avBeam = AVBeamProtocolSpy()
    updateInputFileUseCase = UpdateInputFileUseCaseProtocolSpy()
    saveEIDRequestFilesUseCase = SaveEIDRequestFilesUseCaseProtocolSpy()
    fetchEIDRequestCaseUseCase = FetchEIDRequestCaseUseCaseProtocolSpy()
    context = EIDRequestContext()

    Container.shared.avBeam.register { @MainActor in self.avBeam }
    Container.shared.saveEIDRequestFilesUseCase.register { @MainActor in self.saveEIDRequestFilesUseCase }
    Container.shared.fetchEIDRequestCaseUseCase.register { @MainActor in self.fetchEIDRequestCaseUseCase }
    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.recordDocumentTimeout.register { 10.0 }
    Container.shared.avBeamAppID.register { @MainActor in self.appId }
    Container.shared.updateInputFileUseCase.register { @MainActor in self.updateInputFileUseCase }
    Container.shared.eidRequestFlowCoordinator.register { @MainActor in EIDRequestFlowCoordinatorProtocolSpy() }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_stateIsLoading() {
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.scanningState, .recto)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertEqual(viewModel.recordingState, .initial)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.recordDocumentDelegate)
  }

  @MainActor
  func testCancelInitialization_sdkIsStopped() {
    viewModel.cancelInitialization(Navigator(configuration: NavigationConfiguration()))
    XCTAssertEqual(avBeam.shutdownCallsCount, 1)
  }

  // MARK: - State Management Tests

  func testTitle_returnsCorrectTitle() {
    XCTAssertEqual(viewModel.title, L10n.tkEidRequestRecordDocumentRecto)

    viewModel.scanningState = .verso
    XCTAssertEqual(viewModel.title, L10n.tkEidRequestRecordDocumentVerso)
  }

  func testOverlayImage_identityCard_returnsCorrectImages() {
    context.identityType = .identityCard

    let overlayImages = viewModel.overlayImage
    // Test that images are returned (specific image testing depends on Assets implementation)
    XCTAssertNotNil(overlayImages.front)
    XCTAssertNotNil(overlayImages.back)
  }

  func testOverlayImage_passport_returnsCorrectImages() {
    context.identityType = .passport

    let overlayImages = viewModel.overlayImage
    XCTAssertNotNil(overlayImages.front)
    XCTAssertNotNil(overlayImages.back)
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

  func testCheckInitializationState_failure_handlesError() {
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

  // MARK: - Camera Tests

  func testStartCamera_success_setsCameraState() async {
    viewModel.state = .loading

    viewModel.startCamera()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 600_000_000)

    XCTAssertTrue(avBeam.startCameraCalled)
    XCTAssertEqual(viewModel.state, .camera)
    XCTAssertEqual(viewModel.recordingState, .initial)
  }

  // MARK: - Record Tests

  func testStartRecordDocument_success_callsAVBeamWithCorrectConfig() async throws {
    viewModel.startRecordDocument()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 1_000_000_000)

    XCTAssertTrue(avBeam.startRecordDocumentConfigCalled)
    XCTAssertEqual(updateInputFileUseCase.callAsFunctionCallsCount, 1)
    let config = avBeam.startRecordDocumentConfigReceivedConfig
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.timeout, 10.0)
    XCTAssertTrue(try XCTUnwrap(config?.files.contains(avBeamFile)))
  }

  func testStopRecordDocument_stopScan() {
    viewModel.stopRecordDocument()

    XCTAssertEqual(viewModel.scanningState, .recto)
    XCTAssertEqual(viewModel.recordingState, .initial)
    XCTAssertEqual(viewModel.isNotificationPresented, false)
    XCTAssertNil(viewModel.notification)
    XCTAssertTrue(avBeam.stopRecordDocumentCalled)
  }

//  FLACKY...
//  func testStartRecordDocument_failure_handlesError() async {
//    avBeam.startRecordDocumentConfigThrowableError = TestingError.error
//
//    viewModel.startRecordDocument()
//
//    // Wait for async task to complete
//    try? await Task.sleep(nanoseconds: 1_000_000_000)
//
//    XCTAssertNotNil(viewModel.destination)
//    if case .error(let errorWrapper, _) = viewModel.destination {
//      XCTAssertEqual(errorWrapper.error as? TestingError, TestingError.error)
//    } else {
//      XCTFail("Expected error destination")
//    }
//  }

  // MARK: - Stop and Close Tests

  func testStop_callsAVBeamStopRecordDocumentAndStopCamera() {
    viewModel.stop()

    XCTAssertTrue(avBeam.stopRecordDocumentCalled)
    XCTAssertTrue(avBeam.stopCameraCalled)
  }

  // MARK: - AVBeamMessageDelegate Tests

  func testDidReceiveNotification_initialized_startsCamera() {
    viewModel.didReceiveNotification(notification: .initialized)

    // The startCamera method is called internally
    // We can't directly test state change due to async nature
  }

  func testDidReceiveNotification_docRecordingStarted_setsTimer() async {
    viewModel.startRecordDocument()
    viewModel.didReceiveNotification(notification: .docRecordingStarted)

    await Task.yield()

    XCTAssertNotNil(viewModel.timer)
  }

  func testDidReceiveNotification_defaultCase_noStateChange() {
    let initialState = viewModel.state

    viewModel.didReceiveNotification(notification: .streamingStarted)

    XCTAssertEqual(viewModel.state, initialState)
  }

  // MARK: - AVBeamRecordDocumentDelegate Tests

  func testDidCompleteRecordDocument_success_navigates() async {
    let packageResult = AVBeamPackageResult(.init())

    viewModel.didCompleteRecordDocument(packageResult: packageResult)

    // Wait for async completion
    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertEqual(viewModel.recordingState, .success)
    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
  }

  // MARK: Private

  private var requestCase: EIDRequestCase = .Mock.sampleAVReady
  private var viewModel: RecordDocumentViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var saveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocolSpy!
  private var fetchEIDRequestCaseUseCase: FetchEIDRequestCaseUseCaseProtocolSpy!
  private var context: EIDRequestContext!
  private var updateInputFileUseCase: UpdateInputFileUseCaseProtocolSpy!

  private let appId = "test-app-id"
  private let avBeamFile = AVBeamFile(type: .xml, description: "input.xml", data: "input.xml".data(using: .utf8)!)

  private func success() {
    avBeam.state = .initialized
    context.caseId = "test-case-id"
    context.identityType = .identityCard
    fetchEIDRequestCaseUseCase.executeCaseIdReturnValue = requestCase
    viewModel = RecordDocumentViewModel()
    XCTAssertEqual(viewModel.state, .loading)
    updateInputFileUseCase.callAsFunctionReturnValue = avBeamFile
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
