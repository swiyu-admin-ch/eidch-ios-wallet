import BITTheming
import Factory
import Testing
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
struct WalletPairingViewModelTests {

  // MARK: Lifecycle

  init() {
    let context = EIDRequestContext()
    context.caseId = mockCaseId
    self.context = context

    let pairWalletUseCase = PairWalletUseCaseProtocolSpy()
    pairWalletUseCase.executeForReturnValue = mockPairingId
    self.pairWalletUseCase = pairWalletUseCase

    let startOnlineSessionUseCase = StartOnlineSessionUseCaseProtocolSpy()
    self.startOnlineSessionUseCase = startOnlineSessionUseCase

    let resetRequestCasePairingUseCase = ResetRequestCasePairingUseCaseProtocolSpy()
    self.resetRequestCasePairingUseCase = resetRequestCasePairingUseCase

    let saveWalletPairingIdUseCase = SaveWalletPairingIdUseCaseProtocolSpy()
    self.saveWalletPairingIdUseCase = saveWalletPairingIdUseCase

    Container.shared.eidRequestContext.register { context }
    Container.shared.pairWalletUseCase.register { pairWalletUseCase }
    Container.shared.startOnlineSessionUseCase.register { startOnlineSessionUseCase }
    Container.shared.resetRequestCasePairingUseCase.register { resetRequestCasePairingUseCase }
    Container.shared.saveWalletPairingIdUseCase.register { saveWalletPairingIdUseCase }

    viewModel = WalletPairingViewModel()
  }

  // MARK: Internal

  @Test
  func primaryAction_success() async {
    await viewModel.primaryAction()

    if case .avIdentityCheck(let caseId) = viewModel.destination {
      #expect(caseId == mockCaseId)
    } else {
      Issue.record("Expected destination to be .avIdentityCheck")
    }

    #expect(startOnlineSessionUseCase.executeForCallsCount == 1)
    #expect(startOnlineSessionUseCase.executeForReceivedCaseId == context.caseId)

    #expect(resetRequestCasePairingUseCase.callAsFunctionForCallsCount == 1)
    #expect(resetRequestCasePairingUseCase.callAsFunctionForReceivedCaseId == context.caseId)

    #expect(pairWalletUseCase.executeForCallsCount == 1)
    #expect(pairWalletUseCase.executeForReceivedCaseId == context.caseId)

    #expect(saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCallsCount == 1)
    #expect(saveWalletPairingIdUseCase.callAsFunctionForRequestCaseReceivedArguments?.pairingId == mockPairingId)
    #expect(saveWalletPairingIdUseCase.callAsFunctionForRequestCaseReceivedArguments?.forRequestCase == context.caseId)
  }

  @Test
  func primaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.primaryAction()

    assertError(EIDRequestError.missingCaseId)
  }

  @Test
  func primaryAction_startOnlineSessionThrowsError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    assertError(TestingError.error)
    #expect(resetRequestCasePairingUseCase.callAsFunctionForCallsCount == 1)
    #expect(!pairWalletUseCase.executeForCalled)
    #expect(!saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCalled)
  }

  @Test
  func primaryAction_resetRequestCasePairingThrowsError_routeToError() async {
    resetRequestCasePairingUseCase.callAsFunctionForThrowableError = TestingError.error

    await viewModel.primaryAction()

    assertError(TestingError.error)
    #expect(!startOnlineSessionUseCase.executeForCalled)
    #expect(!pairWalletUseCase.executeForCalled)
    #expect(!saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCalled)
  }

  @Test
  func primaryAction_pairWalletThrowsError_routeToError() async {
    pairWalletUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    assertError(TestingError.error)
    #expect(!saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCalled)
  }

  @Test
  func primaryAction_saveWalletPairingIdThrowsError_routeToError() async {
    saveWalletPairingIdUseCase.callAsFunctionForRequestCaseThrowableError = TestingError.error

    await viewModel.primaryAction()

    assertError(TestingError.error)
    #expect(saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCallsCount == 1)
    #expect(saveWalletPairingIdUseCase.callAsFunctionForRequestCaseReceivedArguments?.pairingId == mockPairingId)
    #expect(saveWalletPairingIdUseCase.callAsFunctionForRequestCaseReceivedArguments?.forRequestCase == context.caseId)
  }

  @Test
  func secondaryAction_success() async {
    await viewModel.secondaryAction()

    if case .walletPairingList(let caseId) = viewModel.destination {
      #expect(caseId == mockCaseId)
    } else {
      Issue.record("Expected destination to be .walletPairingList")
    }

    #expect(startOnlineSessionUseCase.executeForCallsCount == 1)
    #expect(startOnlineSessionUseCase.executeForReceivedCaseId == context.caseId)

    #expect(resetRequestCasePairingUseCase.callAsFunctionForCallsCount == 1)
    #expect(resetRequestCasePairingUseCase.callAsFunctionForReceivedCaseId == context.caseId)

    #expect(!pairWalletUseCase.executeForCalled)
    #expect(!saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCalled)
  }

  @Test
  func secondaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.secondaryAction()

    assertError(EIDRequestError.missingCaseId)
  }

  @Test
  func secondaryAction_startOnlineSessionThrowsError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = TestingError.error

    await viewModel.secondaryAction()

    assertError(TestingError.error)
    #expect(resetRequestCasePairingUseCase.callAsFunctionForCallsCount == 1)
    #expect(!pairWalletUseCase.executeForCalled)
    #expect(!saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCalled)
  }

  @Test
  func secondaryAction_resetRequestCasePairingThrowsError_routeToError() async {
    resetRequestCasePairingUseCase.callAsFunctionForThrowableError = TestingError.error

    await viewModel.secondaryAction()

    assertError(TestingError.error)
    #expect(!startOnlineSessionUseCase.executeForCalled)
    #expect(!pairWalletUseCase.executeForCalled)
    #expect(!saveWalletPairingIdUseCase.callAsFunctionForRequestCaseCalled)
  }

  @Test
  func secondaryAction_startOnlineSessionThrowsInvalidStateError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = SIDRepository.Error.invalidState

    await viewModel.secondaryAction()

    assertError(SIDRepository.Error.invalidState)
  }

  // MARK: Private

  private let mockCaseId = "mockCaseId"
  private let mockPairingId = "mockPairingId"

  private let context: EIDRequestContext
  private let viewModel: WalletPairingViewModel
  private let pairWalletUseCase: PairWalletUseCaseProtocolSpy
  private let startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocolSpy
  private let resetRequestCasePairingUseCase: ResetRequestCasePairingUseCaseProtocolSpy
  private let saveWalletPairingIdUseCase: SaveWalletPairingIdUseCaseProtocolSpy

  private func assertError(_ error: Error) {
    if case .error(let dataset) = viewModel.destination {
      #expect(dataset == ErrorDataset.retry(error) { _ in })
    } else {
      Issue.record("Expected destination to be .error")
    }
  }
}
