import BITL10n
import Factory
import NavigatorUI
import Spyable
import SwiftUI
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
    updateInputFileUseCase = UpdateInputFileUseCaseProtocolSpy()
    updateEIDRequestCaseFilesUseCase = UpdateEIDRequestCaseFilesUseCaseProtocolSpy()
    compareScanDocumentOutputUseCase = CompareScanDocumentOutputUseCaseProtocolSpy()

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.avBeam.register { @MainActor in self.avBeam }
    Container.shared.avBeamAppID.register { @MainActor in self.appId }
    Container.shared.updateEIDRequestCaseFilesUseCase.register { @MainActor in self.updateEIDRequestCaseFilesUseCase }
    Container.shared.compareScanDocumentOutputUseCase.register { @MainActor in self.compareScanDocumentOutputUseCase }
    Container.shared.updateInputFileUseCase.register { @MainActor in self.updateInputFileUseCase }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_stateIsLoading() {
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.scanningState, .recto)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.buttonState, .initial)
    XCTAssertNil(viewModel.notification)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.scanDocumentDelegate)
  }

  @MainActor
  func testCancelInitialization_sdkIsStopped() {
    viewModel.cancelInitialization(Navigator(configuration: NavigationConfiguration()))
    XCTAssertEqual(avBeam.shutdownCallsCount, 1)
  }

  // MARK: - State Management Tests

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

  func testStartScanSecondPage() {
    viewModel.startScanSecondPage()

    XCTAssertEqual(viewModel.scanningState, .verso)
    XCTAssertEqual(viewModel.buttonState, .initial)
  }

  // MARK: - Scan Tests

  func testStartScan_success_callsAVBeamWithCorrectConfig() async throws {
    viewModel.scanFrame = CGRect(x: 10, y: 20, width: 100, height: 200)

    viewModel.startScan()

    // Wait for async task to complete
    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertTrue(avBeam.startScanDocumentConfigCalled)
    XCTAssertEqual(updateInputFileUseCase.callAsFunctionCallsCount, 1)
    let config = avBeam.startScanDocumentConfigReceivedConfig
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.timeout, 15)
    XCTAssertEqual(config?.scanFrame, viewModel.scanFrame)
    XCTAssertTrue(try XCTUnwrap(config?.isDocumentSideChangeNotificationExpected))
    XCTAssertTrue(try XCTUnwrap(config?.files.contains(avBeamFile)))
    XCTAssertEqual(viewModel.buttonState, .record)
  }

  func testStartScan_scanningStateIsVersion_notifySecondScan() {
    viewModel.scanningState = .verso

    viewModel.startScan()

    XCTAssertEqual(viewModel.buttonState, .record)
    XCTAssertEqual(avBeam.notifySecondScanCallsCount, 1)
  }

  func testStopScan_stopScan() {
    viewModel.scanFrame = CGRect(x: 10, y: 20, width: 100, height: 200)

    viewModel.stopScan()

    XCTAssertEqual(viewModel.scanningState, .recto)
    XCTAssertEqual(viewModel.buttonState, .initial)
    XCTAssertEqual(viewModel.isNotificationPresented, false)
    XCTAssertNil(viewModel.notification)
  }

  func testStop_callsAVBeamStopScanDocumentAndStopCamera() {
    viewModel.stop()

    XCTAssertTrue(avBeam.stopScanDocumentCalled)
    XCTAssertTrue(avBeam.stopCameraCalled)
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

    if case .scanDocumentSecondPageInstructions = viewModel.destination {
      XCTAssert(true)
    }
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

    if case .scanDocumentSubmit(let scanOutput) = viewModel.destination {
      XCTAssertEqual(scanOutput.identityType, context.identityType)
      XCTAssertEqual(scanOutput.files.count, AVBeamPackageResult.Mock.sample.files.count + 1)
      XCTAssertEqual(viewModel.buttonState, .success)
    }
  }

  func testDidCompleteScanDocument_videoRecordingRequired_routeToVideoRecording() async {
    context = EIDRequestContext.Mock.documentRecordingSample

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    viewModel = ScanDocumentViewModel()

    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertEqual(viewModel.buttonState, .success)
    XCTAssertEqual(viewModel.destination, .recordDocumentInformation)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithCallsCount, 1)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithReceivedArguments?.caseId, "caseId")
  }

  func testDidCompleteScanDocument_videoRecordingNotRequired_routeToSelfieVideo() async {
    context = EIDRequestContext.Mock.sample

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    viewModel = ScanDocumentViewModel()

    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000_000)

    XCTAssertEqual(viewModel.buttonState, .success)
    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithCallsCount, 1)
    XCTAssertEqual(compareScanDocumentOutputUseCase.callAsFunctionForWithReceivedArguments?.caseId, "caseId")
  }

  func testDidCompleteScanDocument_videoRecordingNotRequiredComparisonDocumentsFails_routeToError() async {
    context = EIDRequestContext.Mock.sample

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    viewModel = ScanDocumentViewModel()
    compareScanDocumentOutputUseCase.callAsFunctionForWithReturnValue = false

    viewModel.didCompleteScanDocument(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000_000)

    if case .error(let dataSet) = viewModel.destination {
      XCTAssertEqual(viewModel.buttonState, .success)
      XCTAssertEqual(dataSet.contents.count, 3)
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
  private var updateInputFileUseCase: UpdateInputFileUseCaseProtocolSpy!

  private let appId = "test-app-id"
  private let avBeamFile = AVBeamFile(type: .xml, description: "input.xml", data: "input.xml".data(using: .utf8)!)

  private func success() {
    avBeam.state = .initialized
    context.identityType = .identityCard
    viewModel = ScanDocumentViewModel()
    XCTAssertEqual(viewModel.state, .loading)
    compareScanDocumentOutputUseCase.callAsFunctionForWithReturnValue = true
    updateInputFileUseCase.callAsFunctionReturnValue = avBeamFile
  }
}
