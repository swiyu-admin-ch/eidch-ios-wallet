import Factory
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// MARK: - NFCScanViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

class NFCScanViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    viewModel = NFCScanViewModel()
    createSuccessCase()
  }

  func testInitState_sdkNotInitialized_stateIsInitilizating() {
    avBeam.state = .notInitialized

    viewModel = NFCScanViewModel()

    XCTAssertEqual(viewModel.state, .sdkInitializing)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.nfcDelegate)
  }

  func testInitState_sdkInitialized_stateIsReady() {
    avBeam.state = .initialized

    viewModel = NFCScanViewModel()

    XCTAssertEqual(viewModel.state, .ready)
    XCTAssertNotNil(avBeam.messageDelegate)
    XCTAssertNotNil(avBeam.nfcDelegate)
  }

  func testInitializateSDK_success() {
    viewModel.initializeSDK()
    XCTAssertTrue(avBeam.initializeUsingCalled)
  }

  func testInitializateSDK_initializeThrowsError() {
    avBeam.initializeUsingThrowableError = TestingError.error

    viewModel.initializeSDK()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
  }

  func testStartNFCScan_success() async {
    await viewModel.startNFCScan()

    XCTAssertEqual(avBeam.startNfcScanConfigCallsCount, 1)
    XCTAssertEqual(avBeam.startNfcScanConfigReceivedConfig, mockNfcConfiguration)

    XCTAssertEqual(avBeamNFCConfigurator.configureForAuthenticationTokenCallsCount, 1)
    XCTAssertEqual(avBeamNFCConfigurator.configureForAuthenticationTokenReceivedArguments?.authenticationToken, mockAutoVerificationResponse.jwt)
    XCTAssertEqual(avBeamNFCConfigurator.configureForAuthenticationTokenReceivedArguments?.caseId, mockCaseId)
  }

  func testStartNFCScan_caseIdMissing_throwsError() async {
    mockContext.caseId = nil

    await viewModel.startNFCScan()

    XCTAssertEqual(viewModel.state, .error(EIDRequestError.missingCaseId))
  }

  func testStartNFCScan_authenticationTokenMissing_throwsError() async {
    mockContext.autoVerificationResponse = nil

    await viewModel.startNFCScan()

    XCTAssertEqual(viewModel.state, .error(EIDRequestError.missingAuthenticationToken))
  }

  func testStartNFCScan_fetchConfigurationFails_throwsError() async {
    avBeamNFCConfigurator.configureForAuthenticationTokenThrowableError = TestingError.error

    await viewModel.startNFCScan()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
  }

  func testStartNFCScan_startNFCScanFails_throwsError() async {
    avBeam.startNfcScanConfigThrowableError = TestingError.error

    await viewModel.startNFCScan()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
  }

  func testDidReceiveNotification_initialized_setsReadyState() {
    viewModel.didReceiveNotification(notification: .initialized)

    XCTAssertEqual(viewModel.state, .ready)
  }

  func testDidCompleteNFCScan_routeToScanResult() {
    avBeam.nfcDelegate?.didCompleteNfcScan(packageResult: mockPackageResult)
    XCTAssertEqual(viewModel.destination, .nfcScanResult(mockPackageResult))
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

    Container.shared.eidRequestContext.register { self.mockContext }
    Container.shared.avBeam.register { self.avBeam }
    Container.shared.avBeamNFCConfigurator.register { self.avBeamNFCConfigurator }
  }

  private func createSuccessCase() {
    avBeamNFCConfigurator.configureForAuthenticationTokenReturnValue = mockNfcConfiguration
  }
}

// MARK: - NFCScanViewModel.State + Equatable

extension NFCScanViewModel.State: Equatable {
  public static func == (lhs: NFCScanViewModel.State, rhs: NFCScanViewModel.State) -> Bool {
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
