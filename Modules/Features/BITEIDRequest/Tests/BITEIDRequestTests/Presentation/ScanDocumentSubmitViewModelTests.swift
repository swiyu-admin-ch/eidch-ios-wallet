import Factory
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

@MainActor
class ScanDocumentSubmitViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    context = EIDRequestContext()
    context.hasLegalRepresentant = true
    context.identityType = .passport
    applyEIDRequestUseCase = ApplyEIDRequestUseCaseProtocolSpy()

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.applyEIDRequestUseCase.register { @MainActor in self.applyEIDRequestUseCase }

    success()
  }

  func testInitialState() {
    XCTAssertNil(viewModel.destination)
    XCTAssertFalse(viewModel.isNavigationCloseTriggered)
    XCTAssertEqual(viewModel.scanImages.count, 2)
  }

  func testSubmit_arguments() async {
    await viewModel.submit()

    XCTAssertEqual(applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReceivedArguments?.scanDocumentOutput, scanDocumentOutput)
    XCTAssertEqual(applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReceivedArguments?.hasLegalRepresentant, true)
  }

  func testSubmit_inQueueStateVerified_routeToQueueInformation() async throws {
    let viewState = try RequestCaseViewState(mockEidRequestCase)

    await viewModel.submit()

    if case .inQueue(let inQueueStateViewModel) = viewState {
      XCTAssertEqual(viewModel.destination, .queueInformation(inQueueStateViewModel.onlineSessionStartOpenAt))
      XCTAssertEqual(context.caseId, mockEidRequestCase.id)
    }
  }

  func testSubmit_emptyFiles_flowContinues() async throws {
    let viewState = try RequestCaseViewState(mockEidRequestCase)
    let scanDocumentOutput = try ScanDocumentOutput(mrz: MRZ(values: MRZ.Mock.sampleValues), identityType: .identityCard)
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)
    await viewModel.submit()

    if case .inQueue(let inQueueStateViewModel) = viewState {
      XCTAssertEqual(viewModel.destination, .queueInformation(inQueueStateViewModel.onlineSessionStartOpenAt))
    }
  }

  func testSubmit_inQueueStateNotVerified_routeToLegalRepresentantConsent() async {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit()

    XCTAssertEqual(viewModel.destination, .legalRepresentantConsent(caseId: mockEidRequestCase.id))
  }

  func testSubmit_readyForOnlineSession_routeToWalletPairing() async {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleAVReady
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    await viewModel.submit()

    XCTAssertEqual(viewModel.destination, .walletPairing)
    XCTAssertEqual(context.caseId, mockEidRequestCase.id)
  }

  func testSubmit_errorHandling_doesNotCrash() async {
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantThrowableError = TestingError.error

    await viewModel.submit()

    XCTAssertTrue(true)
  }

  func testSubmit_appliesMinimumDelay() async {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    let startTime = Date()
    await viewModel.submit()
    let endTime = Date()

    let elapsedTime = endTime.timeIntervalSince(startTime)
    XCTAssertGreaterThanOrEqual(elapsedTime, 1.8)
  }

  func testSubmit_fastResponse_stillAppliesMinimumDelay() async {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    let startTime = Date()
    await viewModel.submit()
    let endTime = Date()

    let elapsedTime = endTime.timeIntervalSince(startTime)
    XCTAssertGreaterThanOrEqual(elapsedTime, 1.8)
  }

  // MARK: Private

  private var context: EIDRequestContext!
  private let scanDocumentOutput = ScanDocumentOutput(mrz: MRZ.Mock.sample, files: EIDRequestCaseFile.Mock.sampleArray, identityType: .identityCard)
  private let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
  private let payload = MRZData.Mock.array.first!.payload

  private var viewModel: ScanDocumentSubmitViewModel!
  private var applyEIDRequestUseCase: ApplyEIDRequestUseCaseProtocolSpy!

  private func success() {
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase
  }

}
