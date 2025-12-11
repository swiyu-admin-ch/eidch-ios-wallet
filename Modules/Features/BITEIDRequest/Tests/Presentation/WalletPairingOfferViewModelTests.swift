// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
final class WalletPairingOfferViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    pollingManager = WalletPairingPollingProtocolSpy()
    fetchWalletPairingOfferUseCase = FetchWalletPairingOfferUseCaseProtocolSpy()
    context = EIDRequestContext()

    Container.shared.walletPairingPollingManager.register { self.pollingManager }
    Container.shared.fetchWalletPairingOfferUseCase.register { self.fetchWalletPairingOfferUseCase }
    Container.shared.eidRequestContext.register { self.context }

    sut = WalletPairingOfferViewModel({ _ in self.didCallHandler = true })
  }

  override func tearDown() {
    sut = nil
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

    context.caseId = expectedCaseId

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
    context.caseId = nil

    await sut.fetchPairingQRCode()

    XCTAssertEqual(sut.state, .error)
    XCTAssertEqual(pollingManager.resetCallsCount, 1)
    XCTAssertEqual(pollingManager.startPollingForPairingIdCallsCount, 0)
    XCTAssertEqual(fetchWalletPairingOfferUseCase.executeForCallsCount, 0)
  }

  func testFetchPairingQRCode_WhenUseCaseThrowsError_ShouldSetErrorState() async {
    let expectedCaseId = "test-case-id"
    context.caseId = expectedCaseId

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
    XCTAssertTrue(sut.isNavigationCloseTriggered)
  }

  func testRetryFetching_ShouldCallFetchPairingQRCode() async {
    let expectedCaseId = "test-case-id"
    context.caseId = expectedCaseId

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

    XCTAssertTrue(didCallHandler)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    XCTAssertTrue(sut.isNavigationCloseTriggered)
  }

  func testPollingManagerDidUpdateState_WhenRejected_ShouldHandleRejection() {
    let pollingState = WalletPairingPollingManager.State.state(.rejected)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertFalse(didCallHandler)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    if case .walletPairingOfferRejected = sut.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected .walletPairingOfferRejected destination, got: \(sut.destination)")
    }
  }

  func testPollingManagerDidUpdateState_WhenOpen_ShouldDoNothing() {
    let pollingState = WalletPairingPollingManager.State.state(.open)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertFalse(didCallHandler)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 0)
    XCTAssertFalse(sut.isNavigationCloseTriggered)
  }

  func testPollingManagerDidUpdateState_WhenError_ShouldHandleError() {
    let errorMessage = "Test error message"
    let pollingState = WalletPairingPollingManager.State.error(errorMessage)

    sut.pollingManager(pollingManager, didUpdateState: pollingState)

    XCTAssertFalse(didCallHandler)
    XCTAssertEqual(pollingManager.stopPollingCallsCount, 1)
    XCTAssertTrue(sut.isNavigationCloseTriggered)
  }

  func testSetState_ShouldUpdateStateWithAnimation() async {
    let expectedCaseId = "test-case-id"
    let expectedQRCodeData = Data("test-qr-code".utf8)

    context.caseId = expectedCaseId

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

  private var sut: WalletPairingOfferViewModel!

  private var context: EIDRequestContext!
  private var pollingManager: WalletPairingPollingProtocolSpy!
  private var fetchWalletPairingOfferUseCase: FetchWalletPairingOfferUseCaseProtocolSpy!

  private var didCallHandler = false
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
