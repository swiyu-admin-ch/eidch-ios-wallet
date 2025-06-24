// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
class MRZScannerViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    router.context.hasLegalRepresentant = true
    submitEIDRequestUseCase = SubmitEIDRequestUseCaseProtocolSpy()

    Container.shared.submitEIDRequestUseCase.register { self.submitEIDRequestUseCase }

    viewModel = MRZScannerViewModel(router: router)
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
    XCTAssertFalse(viewModel.isLoading)
  }

  func testSubmit_inQueueStateVerified_routeToQueueInformation() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    let viewState = try RequestCaseViewState(mockEidRequestCase)
    submitEIDRequestUseCase.executeMrzHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit(payload)

    XCTAssertEqual(submitEIDRequestUseCase.executeMrzHasLegalRepresentantReceivedArguments?.mrz, payload.mrz)
    XCTAssertEqual(submitEIDRequestUseCase.executeMrzHasLegalRepresentantReceivedArguments?.hasLegalRepresentant, true)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)

    if case .inQueue(let inQueueStateViewModel) = viewState {
      XCTAssertEqual(router.queueInformationArgument, inQueueStateViewModel.onlineSessionStartOpenAt)
    }
  }

  func testSubmit_noState_close() async throws {
    submitEIDRequestUseCase.executeMrzHasLegalRepresentantReturnValue = EIDRequestCase.Mock.sampleWithoutState

    await viewModel.submit(payload)

    XCTAssertTrue(router.closeCalled)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
  }

  func testSubmit_inQueueStateNotVerified_routeToLegalRepresentantConsent() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    submitEIDRequestUseCase.executeMrzHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit(payload)

    XCTAssertEqual(router.legalRepresentantConsentArgument, mockEidRequestCase.id)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
  }

  func testSubmit_readyForAVVerified_routeToAutoverificationIDCheck() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleAVReady
    submitEIDRequestUseCase.executeMrzHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit(payload)

    XCTAssertTrue(router.avIdentityCheckCalled)
    XCTAssertFalse(viewModel.isErrorPresented)
    XCTAssertNil(viewModel.errorDescription)
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
  private var router: MockEIDRequestRouter!
  private var viewModel: MRZScannerViewModel!
  private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
