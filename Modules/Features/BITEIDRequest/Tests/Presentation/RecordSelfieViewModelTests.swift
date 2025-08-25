// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import SwiftUI
import UIKit
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// MARK: - RecordSelfieViewModelTests

@MainActor
class RecordSelfieViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    avBeam = AVBeamProtocolSpy()
    saveEIDRequestFilesUseCase = SaveEIDRequestFilesUseCaseProtocolSpy()

    Container.shared.avBeam.register { self.avBeam }
    Container.shared.saveEIDRequestFilesUseCase.register { self.saveEIDRequestFilesUseCase }

    success()
  }

  override func tearDown() {
    Container.shared.reset()
  }

  func testInitialization_sdkNotInitialized_stateIsInitializing() {
    avBeam.state = .notInitialized

    viewModel = RecordSelfieViewModel(router: router)

    XCTAssertEqual(viewModel.state, .sdkInitializing)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertNil(viewModel.notification)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.captureFaceDelegate)
  }

  func testCloseIntroductionPopup_shouldBeNil() {
    XCTAssertTrue(viewModel.isIntroductionPopupPresented)
    viewModel.closeIntroductionPopup()
    XCTAssertFalse(viewModel.isIntroductionPopupPresented)
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

  // MARK: - Record Tests

  func testStartRecord_success_callsAVBeamWithCorrectConfig() async {
    await viewModel.startRecordSelfie()
    await Task.yield()

    XCTAssertTrue(avBeam.startCaptureFaceConfigCalled)
    let config = avBeam.startCaptureFaceConfigReceivedConfig
    XCTAssertEqual(config?.duration, 10)
  }

  func testStartRecord_failure_setsErrorState() async {
    avBeam.startCaptureFaceConfigThrowableError = TestingError.error

    await viewModel.startRecordSelfie()
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

    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
  }

  func testClose_callsStopAndRouter() {
    viewModel.close()

    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: - AVBeamMessageDelegate Tests

  func testDidReceiveNotification_initialized_setsReadyState() async {
    viewModel.didReceiveNotification(notification: .initialized)
    await Task.yield()

    XCTAssertEqual(viewModel.state, .ready)
  }

  func testDidReceiveNotification_faceCapturingStopped_removeAllPopups() async {
    viewModel.didReceiveNotification(notification: .faceCapturingStopped)
    await Task.yield()

    XCTAssertNil(viewModel.notification)
    XCTAssertFalse(viewModel.isNotificationPresented)
    XCTAssertFalse(viewModel.isIntroductionPopupPresented)
  }

  func testDidReceiveNotification_faceCaptureTiltSmile_showsNotification() async {
    viewModel.didReceiveNotification(notification: .faceCaptureTiltSmile)
    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, .faceCaptureTiltSmile)
  }

  func testDidReceiveNotification_faceCaptureStarted_showsNotification() async {
    viewModel.didReceiveNotification(notification: .faceCaptureTiltSmile)
    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, .faceCaptureTiltSmile)
  }

  func testDidReceiveNotification_unknownNotification_showsNotification() async {
    viewModel.didReceiveNotification(notification: .faceCaptureMoveLeft)
    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, .faceCaptureMoveLeft)
  }

  func testDidReceiveNotification_outOfScopeNotification_showsNotification() async {
    viewModel.didReceiveNotification(notification: .dataDecrypted)
    await Task.yield()

    XCTAssertTrue(viewModel.isNotificationPresented)
    XCTAssertEqual(viewModel.notification, .dataDecrypted)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var requestCase: EIDRequestCase = .Mock.sampleAVReady
  private var viewModel: RecordSelfieViewModel!
  private var avBeam: AVBeamProtocolSpy!
  private var saveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocolSpy!

  private let appId = ""

  // MARK: - Initialization Tests

  private func success() {
    avBeam.state = .initialized
    Container.shared.avBeamAppID.register { self.appId }
    router.context.caseId = "1"

    viewModel = RecordSelfieViewModel(router: router)
    XCTAssertEqual(viewModel.state, .ready)
  }

}

// MARK: - RecordSelfieViewModel.StateView + Equatable

extension RecordSelfieViewModel.StateView: Equatable {
  public static func == (lhs: RecordSelfieViewModel.StateView, rhs: RecordSelfieViewModel.StateView) -> Bool {
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
