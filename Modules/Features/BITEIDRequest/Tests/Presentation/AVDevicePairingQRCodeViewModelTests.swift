// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
final class AVDevicePairingQRCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    router = MockEIDRequestRouter()
    delegate = DevicePairingDelegateSpy()
    pollingManager = WalletPairingPollingProtocolSpy()
    fetchWalletPairingOfferUseCase = FetchWalletPairingOfferUseCaseProtocolSpy()

    Container.shared.walletPairingPollingManager.register {
      self.pollingManager
    }
    Container.shared.fetchWalletPairingOfferUseCase.register {
      self.fetchWalletPairingOfferUseCase
    }

    sut = AVDevicePairingQRCodeViewModel(router: router, delegate: delegate)
  }

  override func tearDown() {
    sut = nil
    router = nil
    delegate = nil
    pollingManager = nil
    fetchWalletPairingOfferUseCase = nil
    Container.shared.reset()
    super.tearDown()
  }

  func testInit_ShouldSetupCorrectly() {
    XCTAssertEqual(sut.state, .loading)
    XCTAssertTrue(pollingManager.delegate === sut)
  }

  func testFetchPairingQRCode_WhenCaseIdExists_ShouldFetchSuccessfully() async {
    let expectedCaseId = "test-case-id"
    let expectedPairingId = "test-pairing-id"
    let expectedQRCodeData = Data("test-qr-code".utf8)

    router.context = EIDRequestContext(caseId: expectedCaseId)

    let mockPairingOffer = WalletPairingOffer(
      pairingId: expectedPairingId,
      credentialOfferLink: URL(string: "https://example.com")!,
      qrCodeImageData: expectedQRCodeData)
    fetchWalletPairingOfferUseCase.executeForReturnValue = mockPairingOffer

    await sut.fetchPairingQRCode()

    XCTAssertEqual(sut.state, .result(expectedQRCodeData))
    XCTAssertEqual(pollingManager.resetCallsCount, 1)
    XCTAssertEqual(pollingManager.startPollingForPairingIdCallsCount, 1)

    let pollingArgs = pollingManager.startPollingForPairingIdReceivedArguments
    XCTAssertEqual(pollingArgs?.0, expectedCaseId)
    XCTAssertEqual(pollingArgs?.1, expectedPairingId)

    XCTAssertEqual(fetchWalletPairingOfferUseCase.executeForCallsCount, 1)
    XCTAssertEqual(fetchWalletPairingOfferUseCase.executeForReceivedCaseId, expectedCaseId)
  }

  func testFetchPairingQRCode_WhenCaseIdIsNil_ShouldSetErrorState() async {
    router.context = EIDRequestContext(caseId: nil)

    await sut.fetchPairingQRCode()

    XCTAssertEqual(sut.state, .error)
    XCTAssertEqual(pollingManager.resetCallsCount, 1)
    XCTAssertEqual(pollingManager.startPollingForPairingIdCallsCount, 0)
    XCTAssertEqual(fetchWalletPairingOfferUseCase.executeForCallsCount, 0)
  }

  func testFetchPairingQRCode_WhenUseCaseThrowsError_ShouldSetErrorState() async {
    let expectedCaseId = "test-case-id"
    router.context = EIDRequestContext(caseId: expectedCaseId)

    let expectedError = NSError(domain: "TestError", code: 123, userInfo: nil)
    fetchWalletPairingOfferUseCase.executeForThrowableError = expectedError

    await sut.fetchPairingQRCode()

    XCTAssertEqual(sut.state, .error)
    XCTAssertEqual(pollingManager.resetCallsCount, 2)
    XCTAssertEqual(pollingManager.startPollingForPairingIdCallsCount, 0)
    XCTAssertEqual(fetchWalletPairingOfferUseCase.executeForCallsCount, 1)
  }

  func testClose_ShouldStopPollingAndCallRouter() {
    sut.close()

    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    XCTAssertTrue(router.closeCalled)
  }

  func testRetryFetching_ShouldCallFetchPairingQRCode() async {
    let expectedCaseId = "test-case-id"
    router.context = EIDRequestContext(caseId: expectedCaseId)

    let mockPairingOffer = WalletPairingOffer(
      pairingId: "test-pairing-id",
      credentialOfferLink: URL(string: "https://example.com")!,
      qrCodeImageData: Data("test".utf8))
    fetchWalletPairingOfferUseCase.executeForReturnValue = mockPairingOffer

    await sut.retryFetching()

    XCTAssertEqual(fetchWalletPairingOfferUseCase.executeForCallsCount, 1)
    XCTAssertEqual(pollingManager.resetCallsCount, 1)
    XCTAssertEqual(pollingManager.startPollingForPairingIdCallsCount, 1)
  }

  func testPollingManagerDidUpdateState_WhenAccepted_ShouldNotifyDelegateAndClose() {
    let pollingState = WalletPairingPollingManager.State.state(.accepted)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertEqual(delegate.didPairWalletCallsCount, 1)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    XCTAssertTrue(router.closeCalled)
  }

  func testPollingManagerDidUpdateState_WhenRejected_ShouldHandleRejection() {
    let pollingState = WalletPairingPollingManager.State.state(.rejected)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertEqual(delegate.didPairWalletCallsCount, 0)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    XCTAssertTrue(router.closeCalled)
  }

  func testPollingManagerDidUpdateState_WhenOpen_ShouldDoNothing() {
    let pollingState = WalletPairingPollingManager.State.state(.open)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertEqual(delegate.didPairWalletCallsCount, 0)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 0)
    XCTAssertFalse(router.closeCalled)
  }

  func testPollingManagerDidUpdateState_WhenError_ShouldHandleError() {
    let errorMessage = "Test error message"
    let pollingState = WalletPairingPollingManager.State.error(errorMessage)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertEqual(delegate.didPairWalletCallsCount, 0)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    XCTAssertTrue(router.closeCalled)
  }

  func testSetState_ShouldUpdateStateWithAnimation() async {
    let expectedCaseId = "test-case-id"
    let expectedQRCodeData = Data("test-qr-code".utf8)

    router.context = EIDRequestContext(caseId: expectedCaseId)

    let mockPairingOffer = WalletPairingOffer(
      pairingId: "test-pairing-id",
      credentialOfferLink: URL(string: "https://example.com")!,
      qrCodeImageData: expectedQRCodeData)
    fetchWalletPairingOfferUseCase.executeForReturnValue = mockPairingOffer

    sut.state = .error
    await sut.fetchPairingQRCode()

    XCTAssertEqual(sut.state, .result(expectedQRCodeData))
  }

  // MARK: Private

  private var sut: AVDevicePairingQRCodeViewModel!
  private var router: MockEIDRequestRouter!
  private var delegate: DevicePairingDelegateSpy!
  private var pollingManager: WalletPairingPollingProtocolSpy!
  private var fetchWalletPairingOfferUseCase: FetchWalletPairingOfferUseCaseProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
