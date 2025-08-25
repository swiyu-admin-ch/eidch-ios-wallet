@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import Spyable
import XCTest

@MainActor
class ScanDocumentSubmitViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    router.context.hasLegalRepresentant = true
    submitEIDRequestUseCase = SubmitEIDRequestUseCaseProtocolSpy()

    Container.shared.submitEIDRequestUseCase.register { self.submitEIDRequestUseCase }

    success()
  }

  func testInitialState() {
    XCTAssertNotNil(viewModel)
  }

  func testSubmit_arguments() async throws {
    await viewModel.submit()

    XCTAssertEqual(submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReceivedArguments?.scanDocumentOutput, scanDocumentOutput)
    XCTAssertEqual(submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReceivedArguments?.hasLegalRepresentant, true)
  }

  func testSubmit_inQueueStateVerified_routeToQueueInformation() async throws {
    let viewState = try RequestCaseViewState(mockEidRequestCase)

    await viewModel.submit()

    if case .inQueue(let inQueueStateViewModel) = viewState {
      XCTAssertEqual(router.queueInformationArgument, inQueueStateViewModel.onlineSessionStartOpenAt)
      XCTAssertEqual(router.context.caseId, mockEidRequestCase.id)
    }
  }

  func testSubmit_emptyFiles_flowContinues() async throws {
    let viewState = try RequestCaseViewState(mockEidRequestCase)
    let scanDocumentOutput = try ScanDocumentOutput(mrz: MRZ(values: MRZ.Mock.sampleValues), identityType: .identityCard)
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput, router: router)
    await viewModel.submit()

    if case .inQueue(let inQueueStateViewModel) = viewState {
      XCTAssertEqual(router.queueInformationArgument, inQueueStateViewModel.onlineSessionStartOpenAt)
    }
  }

  func testSubmit_noState_close() async throws {
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = EIDRequestCase.Mock.sampleWithoutState

    await viewModel.submit()

    XCTAssertTrue(router.closeCalled)
  }

  func testSubmit_inQueueStateNotVerified_routeToLegalRepresentantConsent() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit()

    XCTAssertEqual(router.legalRepresentantConsentArgument, mockEidRequestCase.id)
  }

  func testSubmit_readyForOnlineSession_routeToWalletPairing() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleAVReady
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit()

    XCTAssertTrue(router.walletPairingCalled)
    XCTAssertEqual(router.context.caseId, mockEidRequestCase.id)
  }

  func testSubmit_errorHandling_doesNotCrash() async throws {
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantThrowableError = TestingError.error

    await viewModel.submit()

    XCTAssertTrue(true)
  }

  func testSubmit_appliesMinimumDelay() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    let startTime = Date()
    await viewModel.submit()
    let endTime = Date()

    let elapsedTime = endTime.timeIntervalSince(startTime)
    XCTAssertGreaterThanOrEqual(elapsedTime, 1.8)
  }

  func testSubmit_fastResponse_stillAppliesMinimumDelay() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    let startTime = Date()
    await viewModel.submit()
    let endTime = Date()

    let elapsedTime = endTime.timeIntervalSince(startTime)
    XCTAssertGreaterThanOrEqual(elapsedTime, 1.8)
  }

  func testSubmit_defaultCase_closesWhenNoMatchingState() async throws {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleExpired
    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit()

    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private let scanDocumentOutput = ScanDocumentOutput(mrz: MRZ.Mock.sample, files: EIDRequestCaseFile.Mock.sampleArray, identityType: .identityCard)
  private let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
  private let payload = MRZData.Mock.array.first!.payload
  private var router: MockEIDRequestRouter!
  private var viewModel: ScanDocumentSubmitViewModel!
  private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocolSpy!

  private func success() {
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput, router: router)

    submitEIDRequestUseCase.executeScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
