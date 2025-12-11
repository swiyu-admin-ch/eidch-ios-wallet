import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

class AVIdentityCheckViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    context = EIDRequestContext()
    context.caseId = "caseId"
    Container.shared.eidRequestContext.register { self.context }

    registerMocks()
    viewModel = AVIdentityCheckViewModel()
    createSuccessState()
  }

  func testPrimaryAction_nfcRequired_success() async {
    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .nfcScan)
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationResponse)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
  }

  func testPrimaryAction_documentRecordingRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseRecordDocument

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .recordDocument)
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationResponseRecordDocument)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
  }

  func testPrimaryAction_documentScanRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseScanDocument

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .scanDocument)
    XCTAssertEqual(context.autoVerificationResponse, mockAutoVerificationResponseScanDocument)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, context.caseId)
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

  private let mockAutoVerificationResponse = AutoVerificationResponse.Mock.nfcSample
  private let mockAutoVerificationResponseScanDocument = AutoVerificationResponse.Mock.scanDocumentSample
  private let mockAutoVerificationResponseRecordDocument = AutoVerificationResponse.Mock.recordDocumentSample

  private var viewModel: AVIdentityCheckViewModel!
  private var startAutoVerificationUseCase: StartAutoVerificationUseCaseProtocolSpy!
  private var context: EIDRequestContext!

  private func registerMocks() {
    startAutoVerificationUseCase = StartAutoVerificationUseCaseProtocolSpy()
    Container.shared.startAutoVerificationUseCase.register { self.startAutoVerificationUseCase }
  }

  private func createSuccessState() {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponse
  }
}
