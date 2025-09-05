import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

class AVIdentityCheckViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    router = MockEIDRequestRouter()
    router.context.caseId = "caseId"

    registerMocks()
    viewModel = AVIdentityCheckViewModel(router: router)
    createSuccessState()
  }

  func testPrimaryAction_withNFC_success() async {
    await viewModel.primaryAction()

    XCTAssertTrue(router.nfcScanCalled)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, router.context.caseId)
  }

  func testPrimaryAction_withoutNFC_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseNoNFC

    await viewModel.primaryAction()

    XCTAssertTrue(router.recordDocumentCalled)
    XCTAssertEqual(startAutoVerificationUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startAutoVerificationUseCase.executeForReceivedCaseId, router.context.caseId)
  }

  func testPrimaryAction_missingCaseId_routeToError() async {
    router.context.caseId = nil

    await viewModel.primaryAction()

    #warning("TODO: XCTAssert error case here when implemented")
  }

  func testPrimaryAction_startAutoVerificationThrowsError_routeToError() async {
    startAutoVerificationUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    #warning("TODO: XCTAssert error case here when implemented")
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private let mockAutoVerificationResponse = AutoVerificationResponse.Mock.nfcSample
  private let mockAutoVerificationResponseNoNFC = AutoVerificationResponse.Mock.noNfcSample

  private var router: MockEIDRequestRouter!
  private var viewModel: AVIdentityCheckViewModel!
  private var startAutoVerificationUseCase: StartAutoVerificationUseCaseProtocolSpy!

  private func registerMocks() {
    startAutoVerificationUseCase = StartAutoVerificationUseCaseProtocolSpy()
    Container.shared.startAutoVerificationUseCase.register { self.startAutoVerificationUseCase }
  }

  private func createSuccessState() {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponse
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
