// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
final class RequestCasePollingManagerTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    delegate = RequestCasePollingDelegateSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in self.updateEIDRequestCaseStatusUseCase }

    manager = RequestCasePollingManager(pollingInterval: pollingInterval, timeout: timeout)
    manager.delegate = delegate
  }

  override func tearDown() {
    manager.stopPolling()
    manager = nil
    delegate = nil
    updateEIDRequestCaseStatusUseCase = nil
    Container.shared.reset()
    super.tearDown()
  }

  func testStartPolling_WhenNotAlreadyPolling_ShouldStartPolling() async {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAutoVerification

    manager.startPolling(for: caseId)

    await waitForFirstPollingCall()

    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForReceivedRequestCaseId, caseId)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  func testStartPolling_WhenAlreadyPolling_ShouldNotStartAgain() async {
    manager = RequestCasePollingManager(pollingInterval: longPollingInterval, timeout: timeout)
    manager.delegate = delegate
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAutoVerification

    manager.startPolling(for: caseId)
    await waitForFirstPollingCall()
    let initialCallCount = updateEIDRequestCaseStatusUseCase.executeForCallsCount

    manager.startPolling(for: anotherCaseId)

    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, initialCallCount)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForReceivedRequestCaseId, caseId)
  }

  func testStopPolling_WhenPolling_ShouldStopPolling() async {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAutoVerification

    manager.startPolling(for: caseId)
    await waitForFirstPollingCall()
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, 1)

    manager.stopPolling()
    let callCountAfterStop = updateEIDRequestCaseStatusUseCase.executeForCallsCount
    try? await Task.sleep(nanoseconds: additionalPollingWait)

    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, callCountAfterStop)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  func testStopPolling_WhenNotPolling_ShouldDoNothing() {
    manager.stopPolling()

    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, 0)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  func testPolling_WhenStateRemainsAutoVerification_ShouldContinuePolling() async {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAutoVerification

    manager.startPolling(for: caseId)

    try? await Task.sleep(nanoseconds: additionalPollingWait)

    XCTAssertGreaterThan(updateEIDRequestCaseStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  func testPolling_WhenStateLeavesAutoVerification_ShouldStopAndNotifyDelegate() async {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAutoVerification

    manager.startPolling(for: caseId)
    try? await Task.sleep(nanoseconds: stateTransitionWait)
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAgentReview

    await waitForPollingToComplete()

    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 1)
    XCTAssertEqual(delegate.didCompletePollingWithReceivedState, .agentReview)
  }

  func testPolling_WhenUseCaseThrowsError_ShouldStopWithoutNotifyingDelegate() async {
    updateEIDRequestCaseStatusUseCase.executeForThrowableError = TestingError.error

    manager.startPolling(for: caseId)

    try? await Task.sleep(nanoseconds: onePollingCycleWait)
    let callCountAfterFailure = updateEIDRequestCaseStatusUseCase.executeForCallsCount
    try? await Task.sleep(nanoseconds: onePollingCycleWait)

    XCTAssertGreaterThan(callCountAfterFailure, 0)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, callCountAfterFailure)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  func testPolling_WhenRequestCaseStateIsNil_ShouldStopWithoutNotifyingDelegate() async {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleWithoutState

    manager.startPolling(for: caseId)

    try? await Task.sleep(nanoseconds: onePollingCycleWait)
    let callCountAfterNilState = updateEIDRequestCaseStatusUseCase.executeForCallsCount
    try? await Task.sleep(nanoseconds: onePollingCycleWait)

    XCTAssertGreaterThan(callCountAfterNilState, 0)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, callCountAfterNilState)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  func testPolling_WhenTimeoutIsReached_ShouldStopWithoutNotifyingDelegate() async {
    manager = RequestCasePollingManager(pollingInterval: fastPollingInterval, timeout: shortTimeout)
    manager.delegate = delegate
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = .Mock.sampleAutoVerification

    manager.startPolling(for: caseId)

    try? await Task.sleep(nanoseconds: timeoutWait)
    let callCountAfterTimeout = updateEIDRequestCaseStatusUseCase.executeForCallsCount
    try? await Task.sleep(nanoseconds: onePollingCycleWait)

    XCTAssertGreaterThan(callCountAfterTimeout, 0)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, callCountAfterTimeout)
    XCTAssertEqual(delegate.didCompletePollingWithCallsCount, 0)
  }

  // MARK: Private

  private let caseId = "case-id"
  private let anotherCaseId = "another-case-id"
  private let pollingInterval: TimeInterval = 0.05
  private let longPollingInterval: TimeInterval = 0.2
  private let fastPollingInterval: TimeInterval = 0.01
  private let timeout: TimeInterval = 1.0
  private let shortTimeout: TimeInterval = 0.05
  private let onePollingCycleWait: UInt64 = 80_000_000
  private let additionalPollingWait: UInt64 = 180_000_000
  private let stateTransitionWait: UInt64 = 70_000_000
  private let timeoutWait: UInt64 = 120_000_000

  private var manager: RequestCasePollingManager!
  private var delegate: RequestCasePollingDelegateSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!

  private func waitForPollingToComplete(timeout: TimeInterval = 2.0) async {
    let startTime = Date()
    while delegate.didCompletePollingWithCallsCount == 0, Date().timeIntervalSince(startTime) < timeout {
      try? await Task.sleep(nanoseconds: 10_000_000)
    }
  }

  private func waitForFirstPollingCall(timeout: TimeInterval = 1.0) async {
    let startTime = Date()
    while updateEIDRequestCaseStatusUseCase.executeForCallsCount == 0, Date().timeIntervalSince(startTime) < timeout {
      try? await Task.sleep(nanoseconds: 10_000_000)
    }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
