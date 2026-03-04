import Factory
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
@MainActor
class AVIdentityCheckViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    context = EIDRequestContext()
    context.caseId = "caseId"
    Container.shared.eidRequestContext.register { self.context }

    registerMocks()
    viewModel = AVIdentityCheckViewModel()
  }

  func testPrimaryAction_nfcRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationNFCResponse

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .nfcScan)
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationNFCResponse)
    XCTAssertEqual(context.identityType, .passport)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
    XCTAssertEqual(avBeam.initializeUsingCallsCount, 1)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testPrimaryAction_documentRecordingRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseRecordDocument

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .recordDocumentInformation)
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationResponseRecordDocument)
    XCTAssertEqual(context.identityType, .identityCard)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
    XCTAssertEqual(avBeam.initializeUsingCallsCount, 1)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testPrimaryAction_documentScanRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseScanDocument

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .scanDocumentInformation(isBackEnabled: false))
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationResponseScanDocument)
    XCTAssertEqual(context.identityType, .identityCard)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
    XCTAssertEqual(avBeam.initializeUsingCallsCount, 1)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testPrimaryAction_allBooleanFalse_routeToSelfie() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationAllBooleanFalseSample

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationAllBooleanFalseSample)
    XCTAssertEqual(context.identityType, .identityCard)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
    XCTAssertEqual(avBeam.initializeUsingCallsCount, 1)
    XCTAssertEqual(avBeam.initializeUsingReceivedConfig?.appId, appId)
  }

  func testPrimaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.primaryAction()

    #warning("TODO: XCTAssert error case here when implemented")
  }

  func testPrimaryAction_startAutoVerificationThrowsError_routeToError() async {
    startAutoVerificationUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    #warning("TODO: XCTAssert error case here when implemented")
  }

  // MARK: Private

  private let mockAutoVerificationNFCResponse = AutoVerificationResponse.Mock.nfcSample
  private let mockAutoVerificationResponseScanDocument = AutoVerificationResponse.Mock.scanDocumentSample
  private let mockAutoVerificationResponseRecordDocument = AutoVerificationResponse.Mock.recordDocumentSample
  private let mockAutoVerificationAllBooleanFalseSample = AutoVerificationResponse.Mock.allBooleanFalseSample

  private var viewModel: AVIdentityCheckViewModel!
  private var startAutoVerificationUseCase: StartAutoVerificationUseCaseProtocolSpy!
  private var context: EIDRequestContext!
  private var avBeam: AVBeamProtocolSpy!
  private let appId = "test-app-id"

  private func registerMocks() {
    startAutoVerificationUseCase = StartAutoVerificationUseCaseProtocolSpy()
    Container.shared.startAutoVerificationUseCase.register { self.startAutoVerificationUseCase }

    avBeam = AVBeamProtocolSpy()
    avBeam.state = .initialized
    Container.shared.avBeam.register { self.avBeam }
    Container.shared.avBeamAppID.register { self.appId }
  }
}
