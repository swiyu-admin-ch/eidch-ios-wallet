import Factory
import XCTest
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITL10n
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping init_with_name force_try

@MainActor
class WalletPairingListViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    viewModel = WalletPairingListViewModel(router: router)
  }

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  func testInitialState() {
    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertNil(viewModel.toastMessage)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(walletPairingPollingManager.delegate === viewModel)
    XCTAssertFalse(viewModel.isBackButtonHidden)
  }

  func testPairDevice_otherDevice() async {
    await viewModel.pairDevice(.other)

    XCTAssertTrue(router.avDevicePairingQRCodeCalled)
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
  func testPairDevice_currentDevicePairWalletThrows_failure() async {
    pairWalletUseCase.executeForThrowableError = TestingError.error

    await viewModel.pairDevice(.current)

    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
    XCTAssertTrue(walletPairingPollingManager.resetCalled)
  }

  @MainActor
  func testPairDevice_currentDeviceMissingCaseId_failure() async {
    router.context.caseId = nil

    await viewModel.pairDevice(.current)

    XCTAssertEqual(viewModel.currentDevicePairingState, .initial)
  }

  @MainActor
  func testPrimaryAction_success() {
    viewModel.primaryAction()

    XCTAssertTrue(router.avIdentityCheckCalled)
  }

  func testClose() {
    viewModel.close()

    XCTAssertTrue(walletPairingPollingManager.stopPollingCalled)
    XCTAssertTrue(router.closeCalled)
  }

  func testClearToast() {
    viewModel.toastMessage = "Test message"
    viewModel.isToastPresented = true

    viewModel.clearToast()

    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertNil(viewModel.toastMessage)
  }

  // MARK: - DevicePairingDelegate Tests

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
    router.context.caseId = nil

    viewModel.didPairWallet()

    XCTAssertNil(viewModel.toastMessage)
    XCTAssertFalse(viewModel.isToastPresented)

    XCTAssertFalse(fetchEIDRequestStatusUseCase.executeForCalled)
  }

  func testDidPairWallet_withFetchError() async {
    fetchEIDRequestStatusUseCase.executeForThrowableError = TestingError.error

    viewModel.didPairWallet()

    // Toast should still be shown
    XCTAssertEqual(viewModel.toastMessage, L10n.tkEidRequestWalletPairingNotificationSuccess)
    XCTAssertTrue(viewModel.isToastPresented)

    await waitForAsyncTask()

    XCTAssertTrue(fetchEIDRequestStatusUseCase.executeForCalled)

    // State should not be updated on error
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withWrongState_doesNotUpdateUI() async {
    setupStatusResponse(state: .expired, pairedWalletCount: 1, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    // Should not update UI for non-readyForOnlineSession state
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withNoTargetWallets_doesNotUpdateUI() async {
    setupStatusResponse(state: .readyForOnlineSession, pairedWalletCount: 0, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertFalse(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
    XCTAssertFalse(viewModel.isLimitReached)
    XCTAssertTrue(viewModel.isPrimaryButtonDisabled)
  }

  func testDidPairWallet_withZeroPairedWallets_keepsButtonDisabled() async {
    setupStatusResponse(state: .readyForOnlineSession, pairedWalletCount: 0, limitReached: false)

    viewModel.didPairWallet()

    await waitForAsyncTask()

    XCTAssertFalse(viewModel.isBackButtonHidden)
    XCTAssertEqual(viewModel.pairedDevicesCounter, 0)
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

  func testPollingManagerDidUpdateState_acceptedState_updateCurrentDevice() {
    setupSuccessfulStatusResponse()

    let pollingState = WalletPairingPollingManager.State.state(.accepted)

    viewModel.pollingManager(walletPairingPollingManager, didUpdateState: pollingState)

    XCTAssertEqual(walletPairingPollingManager.stopPollingCallsCount, 1)
    XCTAssertEqual(viewModel.isPrimaryButtonDisabled, true)
    XCTAssertEqual(viewModel.currentDevicePairingState, .paired(walletPairingDateFormatter.string(from: Date())))
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

  // MARK: Private

  private let caseId = "testCaseId"
  private let mockPairingId = "testPairingId"
  private var router: MockEIDRequestRouter!
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

    router = MockEIDRequestRouter()
    router.context.caseId = caseId

    pairWalletUseCase = PairWalletUseCaseProtocolSpy()
    pairWalletUseCase.executeForReturnValue = mockPairingId

    walletPairingDateFormatter = DateFormatter(format: "dd.MM.yyyy HH:mm")
    walletPairingPollingManager = WalletPairingPollingProtocolSpy()

    Container.shared.pairWalletUseCase.register { self.pairWalletUseCase }
    Container.shared.walletPairingDateFormatter.register { self.walletPairingDateFormatter }
    Container.shared.walletPairingPollingManager.register { self.walletPairingPollingManager }
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

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
