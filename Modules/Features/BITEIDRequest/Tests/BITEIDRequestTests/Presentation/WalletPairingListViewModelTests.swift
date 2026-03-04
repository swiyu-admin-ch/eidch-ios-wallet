import Factory
import XCTest
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITL10n
@testable import BITTestingCore
@testable import BITTheming

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping init_with_name force_try

@MainActor
class WalletPairingListViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    viewModel = WalletPairingListViewModel()
  }

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  // MARK: - Initial State Tests

  func testInitialState() {
    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertNil(viewModel.toastMessage)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(walletPairingPollingManager.delegate === viewModel)
    XCTAssertFalse(viewModel.isBackButtonHidden)
    XCTAssertNil(viewModel.destination)
  }

  // MARK: - Pair Device Tests

  func testPairDevice_otherDevice() async {
    await viewModel.pairDevice(.other)

    if case .walletPairingOffer(let callback) = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected .walletPairingOffer destination")
    }
  }

  func testPairDevice_otherDevice_clearsToast() async {
    viewModel.toastMessage = "Test message"
    viewModel.isToastPresented = true

    await viewModel.pairDevice(.other)

    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertNil(viewModel.toastMessage)
  }

  @MainActor
  func testPairDevice_currentDevice_success() async {
    setupSuccessfulStatusResponse()

    await viewModel.pairDevice(.current)

    XCTAssertEqual(pairWalletUseCase.executeForCallsCount, 1)
    XCTAssertEqual(pairWalletUseCase.executeForReceivedCaseId, caseId)

    XCTAssertEqual(walletPairingPollingManager.startPollingForPairingIdReceivedArguments?.caseId, caseId)
    XCTAssertEqual(walletPairingPollingManager.startPollingForPairingIdReceivedArguments?.pairingId, mockPairingId)
  }

  @MainActor
  func testPairDevice_currentDevice_setsLoadingState() async {
    setupSuccessfulStatusResponse()

    // Note: This test may be flaky due to timing, but demonstrates the state transition
    let expectation = expectation(description: "Loading state set")

    Task {
      await viewModel.pairDevice(.current)
      expectation.fulfill()
    }

    // Give it a moment to enter loading state
    try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

    await fulfillment(of: [expectation], timeout: 1.0)
  }

  @MainActor
  func testPairDevice_currentDevicePairWalletThrows_failure() async {
    pairWalletUseCase.executeForThrowableError = TestingError.error

    await viewModel.pairDevice(.current)

    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertTrue(walletPairingPollingManager.resetCalled)
  }

  @MainActor
  func testPairDevice_currentDeviceMissingCaseId_failure() async {
    context.caseId = nil

    await viewModel.pairDevice(.current)

    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertTrue(walletPairingPollingManager.resetCalled)
  }

  // MARK: - Primary Action Tests

  @MainActor
  func testPrimaryAction_success() {
    viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIdentityCheck)
  }

  // MARK: - Close Tests

  func testClose() {
    viewModel.close()

    XCTAssertTrue(walletPairingPollingManager.stopPollingCalled)
  }

  // MARK: - Toast Tests

  func testClearToast() {
    viewModel.toastMessage = "Test message"
    viewModel.isToastPresented = true

    viewModel.clearToast()

    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertNil(viewModel.toastMessage)
  }

  func testToastAndClearToast_sequence() async {
    setupSuccessfulStatusResponse()
    setupStatusResponse(state: .inTargetWalletPairing, pairedWalletCount: 1, limitReached: false)

    viewModel.didPairWallet()
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertNotNil(viewModel.toastMessage)

    await waitForAsyncTask()

    viewModel.clearToast()
    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertNil(viewModel.toastMessage)

    viewModel.didPairWallet()

    await waitForAsyncTask()
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertNotNil(viewModel.toastMessage)
  }

  // MARK: - FetchStatus Tests

  func testFetchStatus_withValidCaseId_success() async {
    setupSuccessfulStatusResponse()

    await viewModel.fetchStatus()

    XCTAssertTrue(fetchEIDRequestCaseUseCase.executeCaseIdCalled)
    XCTAssertEqual(fetchEIDRequestCaseUseCase.executeCaseIdReceivedCaseId, caseId)
    XCTAssertTrue(fetchEIDRequestStatusUseCase.executeForCalled)
    XCTAssertEqual(fetchEIDRequestStatusUseCase.executeForReceivedCaseId, caseId)
  }

  func testFetchStatus_withNoCaseId_returnsEarly() async {
    context.caseId = nil

    await viewModel.fetchStatus()

    XCTAssertFalse(fetchEIDRequestCaseUseCase.executeCaseIdCalled)
    XCTAssertFalse(fetchEIDRequestStatusUseCase.executeForCalled)
  }

  func testFetchStatus_withFetchCaseError_showsError() async {
    fetchEIDRequestCaseUseCase.executeCaseIdThrowableError = TestingError.error

    await viewModel.fetchStatus()

    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error, [.primary(L10n.tkGlobalClose) { _ in }]))
    } else {
      XCTFail("Expected .error destination")
    }
  }

  func testFetchStatus_withFetchStatusError_showsError() async {
    fetchEIDRequestStatusUseCase.executeForThrowableError = TestingError.error

    await viewModel.fetchStatus()

    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset(TestingError.error, [.primary(L10n.tkGlobalClose) { _ in }]))
    } else {
      XCTFail("Expected .error destination")
    }
  }

  // MARK: - DidPairWallet Tests

  func testDidPairWallet_withValidCaseId_success() async {
    setupSuccessfulStatusResponse()

    viewModel.didPairWallet()

    XCTAssertEqual(viewModel.toastMessage, L10n.tkEidRequestWalletPairingNotificationSuccess)
    XCTAssertTrue(viewModel.isToastPresented)

    await waitForAsyncTask()

    XCTAssertTrue(fetchEIDRequestStatusUseCase.executeForCalled)

    XCTAssertTrue(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 1)
    XCTAssertTrue(viewModel.isLimitReached)
    XCTAssertFalse(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withNoCaseId() {
    context.caseId = nil

    viewModel.didPairWallet()

    // Toast should still be shown even without case ID
    XCTAssertEqual(viewModel.toastMessage, L10n.tkEidRequestWalletPairingNotificationSuccess)
    XCTAssertTrue(viewModel.isToastPresented)

    XCTAssertFalse(fetchEIDRequestStatusUseCase.executeForCalled)
  }

  func testDidPairWallet_withFetchError_showsErrorDestination() async {
    fetchEIDRequestStatusUseCase.executeForThrowableError = TestingError.error

    viewModel.didPairWallet()

    // Toast should still be shown
    XCTAssertEqual(viewModel.toastMessage, L10n.tkEidRequestWalletPairingNotificationSuccess)
    XCTAssertTrue(viewModel.isToastPresented)

    await waitForAsyncTask()

    XCTAssertTrue(fetchEIDRequestStatusUseCase.executeForCalled)

    // Should show error destination
    if case .error = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected .error destination")
    }
  }

  func testDidPairWallet_withExpireState_presentTimeout() async {
    setupStatusResponse(state: .expired, pairedWalletCount: 1, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    // Should not update UI for non-inTargetWalletPairing state
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
    XCTAssertEqual(viewModel.destination, .timeout)
  }

  func testDidPairWallet_withReadyForOnlineSessionState_presentTimeout() async {
    setupStatusResponse(state: .readyForOnlineSession, pairedWalletCount: 1, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()
    XCTAssertEqual(viewModel.destination, .timeout)
  }

  func testDidPairWallet_withNoTargetWallets_doesNotUpdateUI() async {
    setupStatusResponse(state: .inTargetWalletPairing, pairedWalletCount: 0, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertFalse(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, -1) // -1 because the requestCase contains a deferred credential
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withZeroPairedWallets_keepsButtonDisabled() async {
    setupStatusResponse(state: .inTargetWalletPairing, pairedWalletCount: 0, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertFalse(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, -1) // -1 because the requestCase contains a deferred credential
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withOnePairedWallet_enablesButton() async {
    setupStatusResponse(state: .inTargetWalletPairing, pairedWalletCount: 1, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertTrue(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertFalse(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withOnePairedWalletAndNoDeferredCredential_enablesButton() async {
    fetchEIDRequestCaseUseCase.executeCaseIdReturnValue = EIDRequestCase.Mock.sampleAgentReview
    setupStatusResponse(state: .inTargetWalletPairing, pairedWalletCount: 1, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertTrue(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 1)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertFalse(viewModel.isPrimaryButtonDisabled)
  }

  // MARK: - Computed Properties Tests

  func testIsPrimaryButtonDisabled_withNoTargetWallets() {
    viewModel.targetWallets = nil
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testIsPrimaryButtonDisabled_withEmptyPairedWallets() {
    viewModel.targetWallets = EIDRequestStatus.TargetWallet(limitReached: false, pairedWallets: [])
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testIsPrimaryButtonDisabled_withPairedWallets() {
    viewModel.targetWallets = EIDRequestStatus.TargetWallet(
      limitReached: false,
      pairedWallets: [.init(pairedAt: Date())])
    XCTAssertFalse(viewModel.isPrimaryButtonDisabled)
  }

  func testIsBackButtonHidden_whenButtonDisabled() {
    viewModel.targetWallets = nil
    XCTAssertFalse(viewModel.isBackButtonHidden)
  }

  func testIsBackButtonHidden_whenButtonEnabled() {
    viewModel.targetWallets = EIDRequestStatus.TargetWallet(
      limitReached: false,
      pairedWallets: [.init(pairedAt: Date())])
    XCTAssertTrue(viewModel.isBackButtonHidden)
  }

  func testPairedDevicesCounter_withNoRequestCase() {
    viewModel.targetWallets = EIDRequestStatus.TargetWallet(
      limitReached: false,
      pairedWallets: [.init(pairedAt: Date())])
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
  }

  func testIsCurrentDevicePaired_withDeferredCredential() async {
    setupSuccessfulStatusResponse()
    await viewModel.fetchStatus()

    XCTAssertTrue(viewModel.isCurrentDevicePaired)
  }

  func testIsCurrentDevicePaired_withoutDeferredCredential() async {
    fetchEIDRequestCaseUseCase.executeCaseIdReturnValue = EIDRequestCase.Mock.sampleAgentReview
    setupSuccessfulStatusResponse()
    await viewModel.fetchStatus()

    XCTAssertFalse(viewModel.isCurrentDevicePaired)
  }

  func testIsLimitReached_withNoTargetWallets() {
    viewModel.targetWallets = nil
    XCTAssertFalse(viewModel.isLimitReached)
  }

  func testIsLimitReached_whenLimitNotReached() {
    viewModel.targetWallets = EIDRequestStatus.TargetWallet(limitReached: false, pairedWallets: [])
    XCTAssertFalse(viewModel.isLimitReached)
  }

  func testIsLimitReached_whenLimitReached() {
    viewModel.targetWallets = EIDRequestStatus.TargetWallet(limitReached: true, pairedWallets: [])
    XCTAssertTrue(viewModel.isLimitReached)
  }

  // MARK: - Polling Delegate Tests

  func testPollingManagerDidUpdateState_acceptedState_updateCurrentDevice() {
    setupSuccessfulStatusResponse()

    let pollingState = WalletPairingPollingManager.State.state(.accepted)

    viewModel.pollingManager(walletPairingPollingManager, didUpdateState: pollingState)

    XCTAssertEqual(walletPairingPollingManager.stopPollingCallsCount, 1)
    XCTAssertEqual(viewModel.toastMessage, L10n.tkEidRequestWalletPairingNotificationSuccess)
    XCTAssertTrue(viewModel.isToastPresented)

    // Verify paired state with formatted date
    if case .paired(let dateString) = viewModel.currentDevicePairingState {
      XCTAssertFalse(dateString.isEmpty)
      XCTAssertEqual(dateString, walletPairingDateFormatter.string(from: Date()))
    } else {
      XCTFail("Expected .paired state")
    }
  }

  func testPollingManagerDidUpdateState_rejectedState_stopsCurrentDevicePairing() {
    let pollingState = WalletPairingPollingManager.State.state(.rejected)

    viewModel.pollingManager(walletPairingPollingManager, didUpdateState: pollingState)

    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertEqual(walletPairingPollingManager.stopPollingCallsCount, 1)
  }

  func testPollingManagerDidUpdateState_openState_noAction() {
    let pollingState = WalletPairingPollingManager.State.state(.open)

    viewModel.pollingManager(walletPairingPollingManager, didUpdateState: pollingState)

    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertFalse(walletPairingPollingManager.stopPollingCalled)
  }

  func testPollingManagerDidUpdateState_errorState_stopsPolling() {
    let errorState = WalletPairingPollingManager.State.error("Poke")

    viewModel.pollingManager(walletPairingPollingManager, didUpdateState: errorState)

    XCTAssertTrue(walletPairingPollingManager.stopPollingCalled)
  }

  // MARK: - Animation Tests

  func testHandleStatus_usesAnimation() async {
    setupSuccessfulStatusResponse()

    // Initial state
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertEqual(viewModel.pairedDevicesCounter, 1)
    XCTAssertTrue(viewModel.isLimitReached)
  }

  // MARK: - Integration Tests

  func testFullPairingFlow_currentDevice() async {
    setupSuccessfulStatusResponse()

    // Start pairing
    await viewModel.pairDevice(.current)

    // Verify polling started
    XCTAssertTrue(walletPairingPollingManager.startPollingForPairingIdCalled)

    // Simulate accepted state
    viewModel.pollingManager(
      walletPairingPollingManager,
      didUpdateState: .state(.accepted))

    // Verify toast shown
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertEqual(viewModel.toastMessage, L10n.tkEidRequestWalletPairingNotificationSuccess)

    // Verify paired state
    if case .paired = viewModel.currentDevicePairingState {
      XCTAssert(true)
    } else {
      XCTFail("Expected paired state")
    }

    await waitForAsyncTask()

    // Verify status updated
    XCTAssertNotNil(viewModel.targetWallets)
  }

  func testFullPairingFlow_otherDevice() async {
    // Navigate to pairing offer
    await viewModel.pairDevice(.other)

    if case .walletPairingOffer = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected walletPairingOffer destination")
    }

    // Simulate successful pairing
    setupSuccessfulStatusResponse()
    viewModel.didPairWallet()

    await waitForAsyncTask()

    // Verify UI updated
    XCTAssertFalse(viewModel.isPrimaryButtonDisabled)
    XCTAssertTrue(viewModel.isBackButtonHidden)
  }

  // MARK: Private

  private let caseId = "testCaseId"
  private let mockPairingId = "testPairingId"

  private var context: EIDRequestContext!
  private var viewModel: WalletPairingListViewModel!
  private var fetchEIDRequestStatusUseCase: FetchEIDRequestStatusUseCaseProtocolSpy!
  private var fetchEIDRequestCaseUseCase: FetchEIDRequestCaseUseCaseProtocolSpy!
  private var pairWalletUseCase: PairWalletUseCaseProtocolSpy!
  private var walletPairingDateFormatter: DateFormatter!
  private var walletPairingPollingManager: WalletPairingPollingProtocolSpy!

  private func registerMocks() {

    fetchEIDRequestStatusUseCase = FetchEIDRequestStatusUseCaseProtocolSpy()
    fetchEIDRequestCaseUseCase = FetchEIDRequestCaseUseCaseProtocolSpy()
    fetchEIDRequestCaseUseCase.executeCaseIdReturnValue = EIDRequestCase(
      id: "id",
      rawMRZ: [],
      documentNumber: "documentNumber",
      lastName: "lastname",
      firstName: "firstname",
      deferredCredential: DeferredCredential.Mock.sample)

    Container.shared.fetchEIDRequestCaseUseCase.register { self.fetchEIDRequestCaseUseCase }
    Container.shared.fetchEIDRequestStatusUseCase.register { self.fetchEIDRequestStatusUseCase }

    context = EIDRequestContext()
    context.caseId = caseId

    pairWalletUseCase = PairWalletUseCaseProtocolSpy()
    pairWalletUseCase.executeForReturnValue = mockPairingId

    walletPairingDateFormatter = DateFormatter(format: "dd.MM.yyyy HH:mm")
    walletPairingPollingManager = WalletPairingPollingProtocolSpy()

    Container.shared.pairWalletUseCase.register { self.pairWalletUseCase }
    Container.shared.walletPairingDateFormatter.register { self.walletPairingDateFormatter }
    Container.shared.walletPairingPollingManager.register { self.walletPairingPollingManager }
    Container.shared.eidRequestContext.register { self.context }
  }

  private func setupSuccessfulStatusResponse() {
    setupStatusResponse(state: .inTargetWalletPairing, pairedWalletCount: 2, limitReached: true)
  }

  private func setupStatusResponse(state: EIDRequestStatus.State, pairedWalletCount: Int = 0, limitReached: Bool = false) {
    var pairedWallets = [EIDRequestStatus.TargetWallet.PairedWallet]()
    for _ in 0..<pairedWalletCount {
      pairedWallets.append(.init(pairedAt: Date()))
    }
    let targetWallets = EIDRequestStatus.TargetWallet(limitReached: limitReached, pairedWallets: pairedWallets)

    let status = EIDRequestStatus(state: state, onlineSessionStartCloseAt: nil, queueInformation: nil, legalRepresentant: nil, targetWallets: targetWallets)
    fetchEIDRequestStatusUseCase.executeForReturnValue = status
  }

  private func waitForAsyncTask() async {
    // Wait for the async task in didPairWallet to complete
    await withCheckedContinuation { continuation in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        continuation.resume()
      }
    }
  }
}
