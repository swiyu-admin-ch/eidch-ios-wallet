import Factory
import Testing
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore
@testable import BITTheming

@Suite(.container) @MainActor
struct AVIdentityCheckViewModelTests {

  // MARK: Lifecycle

  init() {
    let context = EIDRequestContext()
    context.caseId = "caseId"
    let startAutoVerificationUseCase = StartAutoVerificationUseCaseProtocolSpy()
    let compareWalletPairingUseCase = CompareWalletPairingUseCaseProtocolSpy()
    let cancelRequestCaseUseCase = CancelRequestCaseUseCaseProtocolSpy()
    let avBeam = AVBeamProtocolSpy()
    avBeam.state = .initialized

    Container.shared.eidRequestContext.register { @MainActor in context }
    Container.shared.startAutoVerificationUseCase.register { @MainActor in startAutoVerificationUseCase }
    Container.shared.compareWalletPairingUseCase.register { @MainActor in compareWalletPairingUseCase }
    Container.shared.cancelRequestCaseUseCase.register { @MainActor in cancelRequestCaseUseCase }
    Container.shared.avBeam.register { @MainActor in avBeam }
    Container.shared.avBeamAppID.register { @MainActor in Self.appId }

    self.context = context
    self.startAutoVerificationUseCase = startAutoVerificationUseCase
    self.compareWalletPairingUseCase = compareWalletPairingUseCase
    self.cancelRequestCaseUseCase = cancelRequestCaseUseCase
    self.avBeam = avBeam
    viewModel = AVIdentityCheckViewModel(caseId: "caseId")
  }

  // MARK: Internal

  @Test
  func primaryAction_nfcRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationNFCResponse

    await viewModel.primaryAction()

    #expect(viewModel.destination == .nfcScan)
    #expect(context.autoVerificationResponse == mockAutoVerificationNFCResponse)
    #expect(context.identityType == .passport)

    assertPrimaryAction_autoVerificationState_avBeamState()
  }

  @Test
  func primaryAction_documentRecordingRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseRecordDocument

    await viewModel.primaryAction()

    #expect(viewModel.destination == .recordDocumentInformation)
    #expect(context.autoVerificationResponse == mockAutoVerificationResponseRecordDocument)
    #expect(context.identityType == .identityCard)

    assertPrimaryAction_autoVerificationState_avBeamState()
  }

  @Test
  func primaryAction_documentScanRequired_success() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationResponseScanDocument

    await viewModel.primaryAction()

    #expect(viewModel.destination == .scanDocumentInformation(isBackEnabled: false))
    #expect(context.autoVerificationResponse == mockAutoVerificationResponseScanDocument)
    #expect(context.identityType == .identityCard)

    assertPrimaryAction_autoVerificationState_avBeamState()
  }

  @Test
  func primaryAction_allBooleanFalse_routeToSelfie() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationAllBooleanFalseSample

    await viewModel.primaryAction()

    #expect(viewModel.destination == .avIntroSelfieVideo)
    #expect(context.autoVerificationResponse == mockAutoVerificationAllBooleanFalseSample)
    #expect(context.identityType == .identityCard)

    assertPrimaryAction_autoVerificationState_avBeamState()
  }

  @Test
  func primaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.primaryAction()

    #expect(viewModel.destination == .error(.retry(EIDRequestError.missingCaseId, { _ in })))
  }

  @Test
  func primaryAction_startAutoVerificationThrowsError_routeToError() async {
    startAutoVerificationUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    #expect(viewModel.destination == .error(.retry(TestingError.error, { _ in })))
  }

  @Test
  func primaryAction_success_comparesWalletPairing() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationAllBooleanFalseSample

    await viewModel.primaryAction()

    #expect(compareWalletPairingUseCase.callAsFunctionForCallsCount == 1)
    #expect(compareWalletPairingUseCase.callAsFunctionForReceivedCaseId == context.caseId)
    #expect(viewModel.destination == .avIntroSelfieVideo)
  }

  @Test
  func primaryAction_compareWalletPairingThrowsInvalidPairingCount_routeToError() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationAllBooleanFalseSample
    compareWalletPairingUseCase.callAsFunctionForThrowableError = CompareWalletPairingUseCaseError.invalidPairingCount

    await viewModel.primaryAction()

    if case .error = viewModel.destination {
      #expect(true)
    } else {
      Issue.record("Destion should be .error")
    }
  }

  @Test
  func primaryAction_compareWalletPairingThrowsNoDevicePaired_routeToRetryError() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationAllBooleanFalseSample
    compareWalletPairingUseCase.callAsFunctionForThrowableError = CompareWalletPairingUseCaseError.noDevicePaired

    await viewModel.primaryAction()

    #expect(viewModel.destination == .error(.retry(CompareWalletPairingUseCaseError.noDevicePaired, { _ in })))
    #expect(cancelRequestCaseUseCase.callAsFunctionForCallsCount == 0)
  }

  @Test
  func primaryAction_compareWalletPairingThrowsOtherError_routeToRetryError() async {
    startAutoVerificationUseCase.executeForReturnValue = mockAutoVerificationAllBooleanFalseSample
    compareWalletPairingUseCase.callAsFunctionForThrowableError = TestingError.error

    await viewModel.primaryAction()

    #expect(viewModel.destination == .error(.retry(TestingError.error, { _ in })))
    #expect(cancelRequestCaseUseCase.callAsFunctionForCallsCount == 0)
  }

  // MARK: Private

  private static let appId = "test-app-id"

  private let mockAutoVerificationNFCResponse = AutoVerificationResponse.Mock.nfcSample
  private let mockAutoVerificationResponseScanDocument = AutoVerificationResponse.Mock.scanDocumentSample
  private let mockAutoVerificationResponseRecordDocument = AutoVerificationResponse.Mock.recordDocumentSample
  private let mockAutoVerificationAllBooleanFalseSample = AutoVerificationResponse.Mock.allBooleanFalseSample

  private let viewModel: AVIdentityCheckViewModel
  private let startAutoVerificationUseCase: StartAutoVerificationUseCaseProtocolSpy
  private let compareWalletPairingUseCase: CompareWalletPairingUseCaseProtocolSpy
  private let cancelRequestCaseUseCase: CancelRequestCaseUseCaseProtocolSpy
  private let context: EIDRequestContext
  private let avBeam: AVBeamProtocolSpy

  private func assertPrimaryAction_autoVerificationState_avBeamState(sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(startAutoVerificationUseCase.executeForCallsCount == 1, sourceLocation: sourceLocation)
    #expect(startAutoVerificationUseCase.executeForReceivedCaseId == context.caseId, sourceLocation: sourceLocation)
    #expect(avBeam.initializeUsingCallsCount == 1, sourceLocation: sourceLocation)
    #expect(avBeam.initializeUsingReceivedConfig?.appId == Self.appId, sourceLocation: sourceLocation)
  }
}
