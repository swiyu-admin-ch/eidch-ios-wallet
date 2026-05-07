import Factory
import XCTest
@testable import swiyu

final class UserInactivityRunnerTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    runner = UserInactivityRunner(timeoutInterval: 2)
  }

  override func tearDown() {
    if let observer = notificationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
    runner = nil
    super.tearDown()
  }

  func testNotificationIsSentOnTimeout() {
    let expectation = expectation(description: "NotificationExpectation")

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      expectation.fulfill()
    }

    let event = UIEvent()
    runner.sendEvent(event)

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testEmptyEventDoesNotPreventTimeout() {
    let expectation = expectation(description: "NotificationExpectation")
    expectation.expectedFulfillmentCount = 1

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      expectation.fulfill()
    }

    runner.sendEvent(UIEvent())

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testAccessibilityFocusResetsTimer() {
    let timeoutExpectation = expectation(description: "NotificationExpectation")
    timeoutExpectation.expectedFulfillmentCount = 1

    let noEarlyTimeout = expectation(description: "NoEarlyTimeout")
    noEarlyTimeout.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      timeoutExpectation.fulfill()
      noEarlyTimeout.fulfill()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    wait(for: [noEarlyTimeout], timeout: 2.4)
    wait(for: [timeoutExpectation], timeout: 1.6)
  }

  func testAccessibilityFocusResetsTimerOnRepeat() {
    let timeoutExpectation = expectation(description: "NotificationExpectation")
    timeoutExpectation.expectedFulfillmentCount = 1

    let noEarlyTimeout = expectation(description: "NoEarlyTimeout")
    noEarlyTimeout.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      timeoutExpectation.fulfill()
      noEarlyTimeout.fulfill()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    wait(for: [noEarlyTimeout], timeout: 3.0)
    wait(for: [timeoutExpectation], timeout: 1.5)
  }

  func testPauseNotificationPreventsTimeoutUntilResume() {
    let timeoutExpectation = expectation(description: "NotificationExpectation")
    timeoutExpectation.expectedFulfillmentCount = 1

    let noTimeoutWhilePaused = expectation(description: "NoTimeoutWhilePaused")
    noTimeoutWhilePaused.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      timeoutExpectation.fulfill()
      noTimeoutWhilePaused.fulfill()
    }

    NotificationCenter.default.post(name: .pauseUserInactivityTimeout, object: nil)

    wait(for: [noTimeoutWhilePaused], timeout: 3)

    NotificationCenter.default.post(name: .resumeUserInactivityTimeout, object: nil)

    wait(for: [timeoutExpectation], timeout: 3)
  }

  func testDisabledTimeoutNeverSchedulesNotification() {
    runner = nil
    runner = UserInactivityRunner(timeoutInterval: .infinity)
    let noTimeoutExpectation = expectation(description: "NoTimeoutWhenDisabled")
    noTimeoutExpectation.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      noTimeoutExpectation.fulfill()
    }

    NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    runner.sendEvent(UIEvent())

    wait(for: [noTimeoutExpectation], timeout: 3)
  }

  func testApplicationLifecycleResetsTimerAfterBecomingActive() {
    runner = nil
    runner = UserInactivityRunner(timeoutInterval: 2)
    let timeoutExpectation = expectation(description: "NotificationExpectation")
    timeoutExpectation.expectedFulfillmentCount = 1

    let noEarlyTimeout = expectation(description: "NoEarlyTimeout")
    noEarlyTimeout.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      timeoutExpectation.fulfill()
      noEarlyTimeout.fulfill()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
      NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    wait(for: [noEarlyTimeout], timeout: 2.4)
    wait(for: [timeoutExpectation], timeout: 1.6)
  }

  func testApplicationForegroundResetsTimerAfterBackground() {
    runner = nil
    runner = UserInactivityRunner(timeoutInterval: 2)
    let timeoutExpectation = expectation(description: "NotificationExpectation")
    timeoutExpectation.expectedFulfillmentCount = 1

    let noEarlyTimeout = expectation(description: "NoEarlyTimeout")
    noEarlyTimeout.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      timeoutExpectation.fulfill()
      noEarlyTimeout.fulfill()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
      NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    wait(for: [noEarlyTimeout], timeout: 2.4)
    wait(for: [timeoutExpectation], timeout: 1.6)
  }

  func testDidLoginCloseResetsTimer() {
    runner = nil
    runner = UserInactivityRunner(timeoutInterval: 2)
    let timeoutExpectation = expectation(description: "NotificationExpectation")
    timeoutExpectation.expectedFulfillmentCount = 1

    let noEarlyTimeout = expectation(description: "NoEarlyTimeout")
    noEarlyTimeout.isInverted = true

    notificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
      timeoutExpectation.fulfill()
      noEarlyTimeout.fulfill()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      NotificationCenter.default.post(name: .didLoginClose, object: nil)
    }

    wait(for: [noEarlyTimeout], timeout: 2.4)
    wait(for: [timeoutExpectation], timeout: 1.6)
  }

  // MARK: Private

  // swiftlint:disable all
  private var runner: UserInactivityRunner!
  private var notificationObserver: NSObjectProtocol!
  // swiftlint:enable all

}
