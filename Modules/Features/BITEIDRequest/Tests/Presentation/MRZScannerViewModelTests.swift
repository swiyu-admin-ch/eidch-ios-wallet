// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
class MRZScannerViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    submitEIDRequestUseCase = SubmitEIDRequestUseCaseProtocolSpy()

    Container.shared.submitEIDRequestUseCase.register { self.submitEIDRequestUseCase }

    viewModel = MRZScannerViewModel(router: router)
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
  }

  func testSubmit_inQueueState_withLegalRepresentant() async throws {
    submitEIDRequestUseCase.executeReturnValue = (mockEidRequestCase, mockEidRequestStatus)

    await viewModel.submit(payload)

    XCTAssertEqual(submitEIDRequestUseCase.executeReceivedMrz, payload.mrz)
    XCTAssertEqual(router.legalRepresentantConsentArgument, mockEidRequestCase.id)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
  }

  func testSubmit_inQueueState_withoutLegalRepresentant() async throws {
    submitEIDRequestUseCase.executeReturnValue = (mockEidRequestCase, mockEidRequestStatusWithoutLegalRepresentant)

    await viewModel.submit(payload)

    XCTAssertEqual(submitEIDRequestUseCase.executeReceivedMrz, payload.mrz)
    XCTAssertEqual(router.queueInformationArgument, mockEidRequestCase.state?.onlineSessionStartOpenAt)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
  }

  func testSubmit_inQueueState_withLegalRepresentantVerified() async throws {
    submitEIDRequestUseCase.executeReturnValue = (mockEidRequestCase, .Mock.inQueueWithVerifiedLegalRepresentant)

    await viewModel.submit(payload)

    XCTAssertFalse(router.legalRepresentantCalled)
  }

  func testSubmit_useCaseThrowsError() async throws {
    submitEIDRequestUseCase.executeThrowableError = TestingError.error

    await viewModel.submit(payload)

    XCTAssertTrue(viewModel.isErrorPresented)
    XCTAssertNotNil(viewModel.errorDescription)
  }

  func testSubmit_useCaseReturnsNoStatus() async throws {
    submitEIDRequestUseCase.executeReturnValue = (mockEidRequestCase, nil)

    await viewModel.submit(payload)

    XCTAssertTrue(router.closeCalled)
  }

  func testSubmit_submitRequestReturnsOtherStateThanInQueue() async throws {
    submitEIDRequestUseCase.executeReturnValue = (.Mock.sampleAVReady, mockEidRequestStatusWithoutLegalRepresentant)

    await viewModel.submit(payload)

    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  func testResetError() {
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
  }

  // MARK: Private

  private let payload = MRZData.Mock.array.first!.payload
  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleInQueue
  private let mockEidRequestStatus: EIDRequestStatus = .Mock.inQueueSample
  private let mockEidRequestStatusWithoutLegalRepresentant: EIDRequestStatus = .Mock.inQueueWithoutLegalRepresentantSample

  private var router: MockEIDRequestRouter!
  private var viewModel: MRZScannerViewModel!
  private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
