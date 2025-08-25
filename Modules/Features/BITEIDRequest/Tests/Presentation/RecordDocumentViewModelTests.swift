// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import SwiftUI
import UIKit
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// MARK: - RecordDocumentViewModelTests

@MainActor
class RecordDocumentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    avBeam = AVBeamProtocolSpy()
    saveEIDRequestFilesUseCase = SaveEIDRequestFilesUseCaseProtocolSpy()
    fetchEIDRequestCaseUseCase = FetchEIDRequestCaseUseCaseProtocolSpy()

    Container.shared.avBeam.register { self.avBeam }
    Container.shared.saveEIDRequestFilesUseCase.register { self.saveEIDRequestFilesUseCase }
    Container.shared.fetchEIDRequestCaseUseCase.register { self.fetchEIDRequestCaseUseCase }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_sdkNotInitialized_stateIsInitializing() {
    avBeam.state = .notInitialized

    viewModel = RecordDocumentViewModel(router: router)

    XCTAssertEqual(viewModel.state, .sdkInitializing)
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
    XCTAssertEqual(viewModel.title, "Recto")

    viewModel.scanningState = .verso
    XCTAssertEqual(viewModel.title, "Verso")
  }

  func testSetup_success_setsIdentityType() async {
    await viewModel.setup()

    XCTAssertEqual(viewModel.state, .ready)
    XCTAssertEqual(router.context.identityType, requestCase.selectedDocumentType)
  }

  func testSetup_failure_stateError() async {
    fetchEIDRequestCaseUseCase.executeCaseIdThrowableError = TestingError.error

    await viewModel.setup()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
  }

  func testCloseIntroductionPopup_shouldBeNil() {
    XCTAssertNotNil(viewModel.introductionPopupState)
    viewModel.closeIntroductionPopup()
    XCTAssertNil(viewModel.introductionPopupState)
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

  // MARK: - Scan Tests

  func testStartScan_success_callsAVBeamWithCorrectConfig() async {
    await viewModel.startRecordDocument()
    await Task.yield()

    XCTAssertTrue(avBeam.startRecordDocumentConfigCalled)
    let config = avBeam.startRecordDocumentConfigReceivedConfig
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.timeout, 10)
  }

  func testStartScan_failure_setsErrorState() async {
    avBeam.startRecordDocumentConfigThrowableError = TestingError.error

    await viewModel.startRecordDocument()
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

    XCTAssertTrue(avBeam.stopRecordDocumentCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
  }

  func testClose_callsStopAndRouter() {
    viewModel.close()

    XCTAssertTrue(avBeam.stopRecordDocumentCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: - AVBeamMessageDelegate Tests

  func testDidReceiveNotification_initialized_setsReadyState() async {
    viewModel.didReceiveNotification(notification: .initialized)

    await Task.yield()

    XCTAssertEqual(viewModel.state, .ready)
  }

  func testDidReceiveNotification_docRecordingStarted_setsTimer() async {
    viewModel.didReceiveNotification(notification: .docRecordingStarted)
    await Task.yield()

    XCTAssertNotNil(viewModel.timer)
  }

  func testDidCompleteRecordDocument_routing_success() async {
    #warning("FLACKY: THREADING issue from the SDK")
//    viewModel.didCompleteRecordDocument(packageResult: .init(.init()))
//
//    XCTAssertTrue(router.avIntroSelfieVideoCalled)
  }

  func testDidCompleteRecordDocument_missingCaseID_Fails() async {
    #warning("FLACKY: THREADING issue from the SDK")
//    router.context.caseId = nil
//    viewModel.didCompleteRecordDocument(packageResult: .init(.init()))
//
//    await Task.yield()
//
//    XCTAssertFalse(router.avIntroSelfieVideoCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var requestCase: EIDRequestCase = .Mock.sampleAVReady
  private var viewModel: RecordDocumentViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var saveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocolSpy!
  private var fetchEIDRequestCaseUseCase: FetchEIDRequestCaseUseCaseProtocolSpy!

  private let appId = ""

  // MARK: - Initialization Tests

  private func success() {
    avBeam.state = .initialized
    Container.shared.avBeamAppID.register { self.appId }
    router.context.identityType = .identityCard
    router.context.caseId = "1"

    viewModel = RecordDocumentViewModel(router: router)
    XCTAssertEqual(viewModel.state, .ready)

    fetchEIDRequestCaseUseCase.executeCaseIdReturnValue = requestCase
  }

}

// MARK: - RecordDocumentViewModel.StateView + Equatable

extension RecordDocumentViewModel.StateView: Equatable {
  public static func == (lhs: RecordDocumentViewModel.StateView, rhs: RecordDocumentViewModel.StateView) -> Bool {
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
