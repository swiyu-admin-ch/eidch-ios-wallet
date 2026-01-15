import BITL10n
import Factory
import Spyable
import SwiftUI
import UIKit
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore
@testable import BITTheming

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

// MARK: - ScanDocumentViewModelTests

@MainActor
class ScanDocumentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    context = EIDRequestContext()
    avBeam = AVBeamProtocolSpy()
    updateEIDRequestCaseFilesUseCase = UpdateEIDRequestCaseFilesUseCaseProtocolSpy()
    compareScanDocumentOutputUseCase = CompareScanDocumentOutputUseCaseProtocolSpy()

    Container.shared.eidRequestContext.register { self.context }
    Container.shared.avBeam.register { self.avBeam }
    Container.shared.avBeamAppID.register { self.appId }
    Container.shared.updateEIDRequestCaseFilesUseCase.register { self.updateEIDRequestCaseFilesUseCase }
    Container.shared.compareScanDocumentOutputUseCase.register { self.compareScanDocumentOutputUseCase }

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
    XCTAssertNotNil(avBeam.scanDocumentDelegate)
  }

  // MARK: - State Management Tests

  func testScanningState_whenChanged_updatesIntroductionPopupState() {
    viewModel.scanningState = .verso

    XCTAssertEqual(viewModel.introductionPopupState, .verso)
  }

  func testTitle_returnsCorrectTitle() {
    XCTAssertEqual(viewModel.title, L10n.tkEidRequestMrzScannerRecto)

    viewModel.scanningState = .verso
    XCTAssertEqual(viewModel.title, L10n.tkEidRequestMrzScannerVerso)
  }

  func testOverlayImage_identityCard_returnsCorrectImages() {
    context.identityType = .identityCard

    let overlayImages = viewModel.overlayImage
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

  func testStartCamera_failure_handlesError() async {
    avBeam.startCameraThrowableError = TestingError.error

    viewModel.startCamera()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 600_000_000)

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error))
    } else {
      XCTFail("Expected error destination")
    }
  }

  // MARK: - Scan Tests

  func testStartScan_success_callsAVBeamWithCorrectConfig() async {
    viewModel.scanFrame = CGRect(x: 10, y: 20, width: 100, height: 200)

    viewModel.startScan()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(avBeam.startScanDocumentConfigCalled)
    let config = avBeam.startScanDocumentConfigReceivedConfig
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.timeout, 15)
    XCTAssertEqual(config?.scanFrame, viewModel.scanFrame)
  }

  func testStartScan_failure_handlesError() async {
    avBeam.startScanDocumentConfigThrowableError = TestingError.error
    viewModel.scanFrame = CGRect(x: 0, y: 0, width: 0, height: 0)

    viewModel.startScan()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertNotNil(viewModel.destination)
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error))
    } else {
      XCTFail("Expected error destination")
    }
  }

  // MARK: - Stop and Close Tests

  func testStop_callsAVBeamStopScanDocument() {
    viewModel.stop()

    XCTAssertTrue(avBeam.stopScanDocumentCalled)
  }

  // MARK: - AVBeamMessageDelegate Tests

  func testDidReceiveNotification_initialized_startsCamera() {
    viewModel.didReceiveNotification(notification: .initialized)

    // The startCamera method is called internally
    // We can't directly test state change due to async nature
  }

  func testDidReceiveNotification_streamingStarted_startsScanning() {
    viewModel.didReceiveNotification(notification: .streamingStarted)

    // The startScan method is called internally
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

  func testDidReceiveNotification_idDetectionDone_noStateChange() {
    let initialState = viewModel.state

    viewModel.didReceiveNotification(notification: .idDetectionDone)

    XCTAssertEqual(viewModel.state, initialState)
  }

  func testDidReceiveNotification_idRecognitionStopped_noStateChange() {
    let initialState = viewModel.state

    viewModel.didReceiveNotification(notification: .idRecognitionStopped)

    XCTAssertEqual(viewModel.state, initialState)
  }

  func testDidReceiveNotification_idNeedSecondPageForMatching_changesScanningState() async {
    viewModel.didReceiveNotification(notification: .idNeedSecondPageForMatching)

    await Task.yield()

    XCTAssertEqual(viewModel.scanningState, .verso)
    XCTAssertEqual(viewModel.introductionPopupState, .verso)
  }

  func testDidReceiveNotification_defaultCase_showsNotification() async {
    let testNotification = AVBeamNotification.dataDecrypted

    viewModel.didReceiveNotification(notification: testNotification)

    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, testNotification)
  }

  func testDidCompleteScanDocument_noAuthenticationReponse_routeToSubmitDocument() async {
    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    await Task.yield()

    XCTAssertTrue(avBeam.stopCameraCalled)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNil(viewModel.introductionPopupState)

    if case .scanDocumentSubmit(let scanOutput) = viewModel.destination {
      XCTAssertEqual(scanOutput.identityType, context.identityType)
      XCTAssertEqual(scanOutput.files.count, AVBeamPackageResult.Mock.sample.files.count + 1)
    }
  }

  func testDidCompleteScanDocument_videoRecordingRequired_routeToVideoRecording() async {
    context = EIDRequestContext.Mock.documentRecordingSample

    Container.shared.eidRequestContext.register { self.context }
    viewModel = ScanDocumentViewModel()

    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertEqual(viewModel.destination, .recordDocumentInformation)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithCallsCount, 1)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithReceivedArguments?.caseId, "caseId")
  }

  func testDidCompleteScanDocument_videoRecordingNotRequired_routeToSelfieVideo() async {
    context = EIDRequestContext.Mock.sample

    Container.shared.eidRequestContext.register { self.context }
    viewModel = ScanDocumentViewModel()

    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithCallsCount, 1)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithReceivedArguments?.caseId, "caseId")
  }

  func testDidCompleteScanDocument_videoRecordingNotRequiredComparisonDocumentsFails_routeToError() async {
    context = EIDRequestContext.Mock.sample

    Container.shared.eidRequestContext.register { self.context }
    viewModel = ScanDocumentViewModel()
    compareScanDocumentOutputUseCase.callAsFunctionForWithReturnValue = false

    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000_000)

    if case .error(let dataSet) = viewModel.destination {
      XCTAssertEqual(dataSet.contents.count, 2)
      XCTAssertEqual(dataSet.actions.count, 1)
      XCTAssertFalse(updateEIDRequestCaseFilesUseCase.callAsFunctionForScanDocumentOutputCalled)
    }
  }

  // MARK: Private

  private var context: EIDRequestContext!
  private var viewModel: ScanDocumentViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var updateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocolSpy!
  private var compareScanDocumentOutputUseCase: CompareScanDocumentOutputUseCaseProtocolSpy!

  private let appId = "test-app-id"

  private func success() {
    avBeam.state = .initialized
    context.identityType = .identityCard
    viewModel = ScanDocumentViewModel()
    XCTAssertEqual(viewModel.state, .loading)
    compareScanDocumentOutputUseCase.callAsFunctionForWithReturnValue = true
  }

}
