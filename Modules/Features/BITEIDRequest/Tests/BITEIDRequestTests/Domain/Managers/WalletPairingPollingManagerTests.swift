// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
final class WalletPairingPollingManagerTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    delegate = WalletPairingPollingDelegateSpy()
    fetchWalletPairingStateUseCase = FetchWalletPairingStateUseCaseProtocolSpy()
    Container.shared.fetchWalletPairingStateUseCase.register { @MainActor in self.fetchWalletPairingStateUseCase }

    sut = WalletPairingPollingManager(pollingInterval: 0.1)
    sut.delegate = delegate
  }

  override func tearDown() {
    sut.stopPolling()
    sut = nil
    delegate = nil
    fetchWalletPairingStateUseCase = nil
    Container.shared.reset()
    super.tearDown()
  }

  func testInitialState() {
    XCTAssertFalse(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.open))
    XCTAssertNotNil(sut.delegate)
  }

  func testStartPolling_WhenNotAlreadyPolling_ShouldStartPollingAndUpdateState() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .open

    sut.startPolling(for: caseId, pairingId: pairingId)

    await Task.yield()

    XCTAssertTrue(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.open))
    XCTAssertEqual(delegate.pollingManagerDidUpdateStateReceivedArguments?.state, .state(.open))
  }

  func testStartPolling_WhenAlreadyPolling_ShouldNotStartAgain() {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .open

    sut.startPolling(for: caseId, pairingId: pairingId)
    let initialCallCount = delegate.pollingManagerDidUpdateStateCallsCount

    sut.startPolling(for: caseId, pairingId: pairingId)

    XCTAssertEqual(delegate.pollingManagerDidUpdateStateCallsCount, initialCallCount)
  }

  func testStopPolling_WhenPolling_ShouldStopPolling() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .open

    sut.startPolling(for: caseId, pairingId: pairingId)
    await Task.yield()
    XCTAssertTrue(sut.isPolling)

    sut.stopPolling()

    XCTAssertFalse(sut.isPolling)
  }

  func testStopPolling_WhenNotPolling_ShouldDoNothing() {
    XCTAssertFalse(sut.isPolling)

    sut.stopPolling()

    XCTAssertFalse(sut.isPolling)
  }

  func testReset_ShouldStopPollingAndResetState() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .accepted

    sut.startPolling(for: caseId, pairingId: pairingId)
    await Task.yield()

    sut.reset()

    XCTAssertFalse(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.open))
    XCTAssertGreaterThanOrEqual(delegate.pollingManagerDidUpdateStateCallsCount, 2)
  }

  func testPolling_WhenStateIsAccepted_ShouldStopPollingAndNotifyDelegate() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .accepted

    sut.startPolling(for: caseId, pairingId: pairingId)

    await waitForPollingToStop()

    XCTAssertFalse(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.accepted))
    XCTAssertGreaterThanOrEqual(delegate.pollingManagerDidUpdateStateCallsCount, 2)

    let lastCall = delegate.pollingManagerDidUpdateStateReceivedInvocations.last
    XCTAssertEqual(lastCall?.state, .state(.accepted))
  }

  func testPolling_WhenStateIsRejected_ShouldStopPollingAndNotifyDelegate() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .rejected

    sut.startPolling(for: caseId, pairingId: pairingId)

    await waitForPollingToStop()

    XCTAssertFalse(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.rejected))
    XCTAssertGreaterThanOrEqual(delegate.pollingManagerDidUpdateStateCallsCount, 2)

    let lastCall = delegate.pollingManagerDidUpdateStateReceivedInvocations.last
    XCTAssertEqual(lastCall?.state, .state(.rejected))
  }

  func testPolling_WhenStateRemainsOpen_ShouldContinuePolling() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    fetchWalletPairingStateUseCase.executeForPairingIdReturnValue = .open

    sut.startPolling(for: caseId, pairingId: pairingId)

    try? await Task.sleep(nanoseconds: 250_000_000)

    XCTAssertTrue(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.open))
    XCTAssertGreaterThan(fetchWalletPairingStateUseCase.executeForPairingIdCallsCount, 1)
  }

  func testPolling_WhenUseCaseThrowsError_ShouldStopPollingAndSetErrorState() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"
    let expectedError = NSError(domain: "TestError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error message"])
    fetchWalletPairingStateUseCase.executeForPairingIdThrowableError = expectedError

    sut.startPolling(for: caseId, pairingId: pairingId)

    await waitForPollingToStop()

    XCTAssertFalse(sut.isPolling)
    XCTAssertEqual(sut.state, .error("Test error message"))

    let lastCall = delegate.pollingManagerDidUpdateStateReceivedInvocations.last
    XCTAssertEqual(lastCall?.state, .error("Test error message"))
  }

  func testPolling_StateTransition_OpenToAccepted() async {
    let caseId = "test-case-id"
    let pairingId = "test-pairing-id"

    var callCount = 0
    fetchWalletPairingStateUseCase.executeForPairingIdClosure = { _, _ in
      callCount += 1
      if callCount == 1 {
        return .open
      }
      return .accepted
    }

    sut.startPolling(for: caseId, pairingId: pairingId)

    await waitForPollingToStop()

    XCTAssertFalse(sut.isPolling)
    XCTAssertEqual(sut.state, .state(.accepted))

    let stateUpdates = delegate.pollingManagerDidUpdateStateReceivedInvocations.map(\.state)
    XCTAssertTrue(stateUpdates.contains(.state(.open)))
    XCTAssertTrue(stateUpdates.contains(.state(.accepted)))
  }

  // MARK: Private

  private var sut: WalletPairingPollingManager!
  private var delegate: WalletPairingPollingDelegateSpy!
  private var fetchWalletPairingStateUseCase: FetchWalletPairingStateUseCaseProtocolSpy!

  private func waitForPollingToStop(timeout: TimeInterval = 2.0) async {
    let startTime = Date()
    while sut.isPolling && Date().timeIntervalSince(startTime) < timeout {
      try? await Task.sleep(nanoseconds: 10_000_000)
    }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
