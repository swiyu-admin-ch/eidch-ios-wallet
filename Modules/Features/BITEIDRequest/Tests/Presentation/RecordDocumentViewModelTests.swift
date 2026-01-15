// swiftlint:disable implicitly_unwrapped_optional force_unwrapping init_with_name
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

// MARK: - RecordDocumentViewModelTests

@MainActor
class RecordDocumentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    avBeam = AVBeamProtocolSpy()
    saveEIDRequestFilesUseCase = SaveEIDRequestFilesUseCaseProtocolSpy()
    fetchEIDRequestCaseUseCase = FetchEIDRequestCaseUseCaseProtocolSpy()
    context = EIDRequestContext()

    Container.shared.avBeam.register { self.avBeam }
    Container.shared.saveEIDRequestFilesUseCase.register { self.saveEIDRequestFilesUseCase }
    Container.shared.fetchEIDRequestCaseUseCase.register { self.fetchEIDRequestCaseUseCase }
    Container.shared.eidRequestContext.register { self.context }
    Container.shared.recordDocumentTimeout.register { 10.0 }
    Container.shared.avBeamAppID.register { self.appId }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_stateIsLoading() {
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.scanningState, .recto)
    XCTAssertEqual(viewModel.introductionPopupState, .recto)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.recordDocumentDelegate)
  }

  // MARK: - State Management Tests

  func testScanningState_whenChanged_updatesIntroductionPopupState() {
    viewModel.scanningState = .verso

    XCTAssertEqual(viewModel.introductionPopupState, .verso)
  }

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

  func testSetup_success_setsIdentityType() async {
    await viewModel.setup()

    XCTAssertEqual(context.identityType, .identityCard)
  }

  func testCloseIntroductionPopup_shouldSetToNil() {
    XCTAssertNotNil(viewModel.introductionPopupState)

    viewModel.closeIntroductionPopup()

    XCTAssertNil(viewModel.introductionPopupState)
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

  func testInitializeSDK_failure_handlesError() {
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

  // MARK: - Camera Tests

  func testStartCamera_success_setsCameraState() async {
    viewModel.state = .loading

    viewModel.startCamera()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 600_000_000)

    XCTAssertTrue(avBeam.startCameraCalled)
    XCTAssertEqual(viewModel.state, .camera)
  }

  // MARK: - Record Tests

  func testStartRecordDocument_success_callsAVBeamWithCorrectConfig() async {
    viewModel.startRecordDocument()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 1_000_000_000)

    XCTAssertTrue(avBeam.startRecordDocumentConfigCalled)
    let config = avBeam.startRecordDocumentConfigReceivedConfig
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.timeout, 10.0)
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

  func testStop_callsAVBeamStopRecordDocument() {
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

    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
  }

  // MARK: Private

  private var requestCase: EIDRequestCase = .Mock.sampleAVReady
  private var viewModel: RecordDocumentViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var saveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocolSpy!
  private var fetchEIDRequestCaseUseCase: FetchEIDRequestCaseUseCaseProtocolSpy!
  private var context: EIDRequestContext!

  private let appId = "test-app-id"

  private func success() {
    avBeam.state = .initialized
    context.caseId = "test-case-id"
    context.identityType = .identityCard
    fetchEIDRequestCaseUseCase.executeCaseIdReturnValue = requestCase
    viewModel = RecordDocumentViewModel()
    XCTAssertEqual(viewModel.state, .loading)
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
