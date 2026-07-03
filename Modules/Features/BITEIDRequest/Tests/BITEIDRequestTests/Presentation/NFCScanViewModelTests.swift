import BITL10n
import Factory
import NavigatorUI
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore
@testable import BITTheming

// MARK: - NFCScanViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

@MainActor
class NFCScanViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()
    registerMocks()
    viewModel = NFCScanViewModel()
    createSuccessCase()
  }

  func testInitialState_whenSDKInitialized_stateIsReady() {
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.nfcDelegate)
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertNil(viewModel.destination)
  }

  func testInitializateSDK_notInitialized_callInitialize() {
    avBeam.state = .notInitialized

    viewModel.checkInitializationState()

    XCTAssertEqual(avBeam.initializeUsingCallsCount, 1)
  }

  func testInitializateSDK_initialized_stateIsReady() {
    avBeam.state = .initialized

    viewModel.checkInitializationState()

    XCTAssertEqual(viewModel.state, .loading)
  }

  func testInitializateSDK_initializeThrowsError_routeToError() {
    avBeam.state = .notInitialized
    avBeam.initializeUsingThrowableError = TestingError.error

    viewModel.checkInitializationState()

    if case .error = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("viewModel.destination should be .error")
    }
  }

  func testStartNFCScan_success() async {
    await viewModel.startNFCScan()

    XCTAssertEqual(avBeam.startNfcScanConfigCallsCount, 1)
    XCTAssertEqual(avBeam.startNfcScanConfigReceivedConfig, mockNfcConfiguration)

    XCTAssertEqual(avBeamNFCConfigurator.configureForAuthenticationTokenCallsCount, 1)
    XCTAssertEqual(avBeamNFCConfigurator.configureForAuthenticationTokenReceivedArguments?.authenticationToken, mockAutoVerificationResponse.jwt)
    XCTAssertEqual(avBeamNFCConfigurator.configureForAuthenticationTokenReceivedArguments?.caseId, mockCaseId)
  }

  func testStartNFCScan_missingCaseId_routeToError() async {
    mockContext.caseId = nil

    await viewModel.startNFCScan()

    if case .error = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("viewModel.destination should be .error")
    }
  }

  func testStartNFCScan_missingAuhtenticationToken_routeToError() async {
    mockContext.autoVerificationResponse = nil

    await viewModel.startNFCScan()

    if case .error = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("viewModel.destination should be .error")
    }
  }

  func testStartNFCScan_fetchConfigurationFails_throwsError() async {
    avBeamNFCConfigurator.configureForAuthenticationTokenThrowableError = TestingError.error

    await viewModel.startNFCScan()

    if case .error = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("viewModel.destination should be .error")
    }
  }

  func testDidReceiveNotification_initialized_setsReadyState() async {
    viewModel.didReceiveNotification(notification: .initialized)

    await Task.yield()

    XCTAssertEqual(viewModel.state, .ready)
  }

  func testDidCompleteNfcScan_successfully_routeToNfcResult() async {
    viewModel.didCompleteNfcScan(packageResult: .Mock.sample)

    try? await Task.sleep(nanoseconds: 100_000)

    XCTAssertEqual(viewModel.destination, .nfcScanResult(mockPackageResult))
  }

  func testDidCompleteNfcScan_nfcError_routeToError() async {
    mockContext = EIDRequestContext.Mock.scanDocumentSample

    Container.shared.eidRequestContext.register { @MainActor in self.mockContext }
    viewModel = NFCScanViewModel()

    let error = AVBeamError.nfcTechnicalError

    viewModel.didCompleteNfcScan(packageResult: .Mock.with(nfcError: error))

    try? await Task.sleep(nanoseconds: 100_000)

    XCTAssertEqual(viewModel.destination, .error(.NFC.retry(error, { _ in })))
  }

  func testDidCompleteNfcScan_nfcTimeout_doesNothing() async {
    viewModel.didCompleteNfcScan(packageResult: .Mock.with(nfcError: .nfcSessionInvalidated))

    try? await Task.sleep(nanoseconds: 100_000)

    XCTAssertNil(viewModel.destination)
  }

  func testDidCompleteNfcScan_avError_routeToError() async {
    mockContext = EIDRequestContext.Mock.scanDocumentSample

    Container.shared.eidRequestContext.register { @MainActor in self.mockContext }
    viewModel = NFCScanViewModel()

    let error = AVBeamError.faceCaptureGeneric

    viewModel.didCompleteNfcScan(packageResult: .Mock.with(errorCode: error))

    try? await Task.sleep(nanoseconds: 100_000)

    XCTAssertEqual(viewModel.destination, .error(.NFC.retry(error, { _ in })))
  }

  func testDidCompleteNfcScan_thirdFailure_routeToRetryAndContinue() async {
    mockContext = EIDRequestContext.Mock.scanDocumentSample

    Container.shared.eidRequestContext.register { @MainActor in self.mockContext }
    Container.shared.maxFailedNFCScanAttempts.register { 3 }
    viewModel = NFCScanViewModel()

    let error = AVBeamError.nfcTechnicalError

    viewModel.didCompleteNfcScan(packageResult: .Mock.with(nfcError: error))
    viewModel.didCompleteNfcScan(packageResult: .Mock.with(nfcError: error))
    viewModel.didCompleteNfcScan(packageResult: .Mock.with(nfcError: error))

    try? await Task.sleep(nanoseconds: 100_000)

    XCTAssertEqual(viewModel.destination, .error(.NFC.retryOrContinue(error, continueAction: { _ in }, retryAction: { _ in })))
  }

  // MARK: Private

  private var viewModel: NFCScanViewModel!

  private let mockCaseId = "caseId"
  private let mockAutoVerificationResponse = AutoVerificationResponse.Mock.nfcSample
  private let mockPackageResult = AVBeamPackageResult.Mock.sample
  private let mockNfcConfiguration = AVBeamScanNfcConfig.Mock.sample
  private var mockContext: EIDRequestContext!

  private var avBeam: AVBeamProtocolSpy!
  private var avBeamNFCConfigurator: AVBeamNFCConfiguratorProtocolSpy!

  private func registerMocks() {
    avBeamNFCConfigurator = AVBeamNFCConfiguratorProtocolSpy()
    avBeam = AVBeamProtocolSpy()
    avBeam.state = .initialized

    mockContext = EIDRequestContext(caseId: mockCaseId, autoVerificationResponse: mockAutoVerificationResponse)

    Container.shared.eidRequestContext.register { @MainActor in self.mockContext }
    Container.shared.avBeam.register { @MainActor in self.avBeam }
    Container.shared.avBeamNFCConfigurator.register { @MainActor in self.avBeamNFCConfigurator }
    Container.shared.maxFailedNFCScanAttempts.register { 3 }
    Container.shared.eidRequestFlowCoordinator.register { @MainActor in EIDRequestFlowCoordinatorProtocolSpy() }
  }

  private func createSuccessCase() {
    avBeamNFCConfigurator.configureForAuthenticationTokenReturnValue = mockNfcConfiguration
  }
}

// MARK: - NFCScanViewModel.State + Equatable

extension NFCScanViewModel.State: Equatable {
  public static func == (lhs: NFCScanViewModel.State, rhs: NFCScanViewModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading):
      true
    case (.ready, .ready):
      true
    default:
      false
    }
  }
}
