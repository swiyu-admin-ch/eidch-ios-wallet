import Factory
import Foundation
import Testing
import UIKit
@testable import swiyu

extension EventInterceptor {
  static func resetEventHandlerForTesting() {
    eventHandler = { userActivityDetector.sendEvent($0) }
  }
}

// MARK: - UserActivityDetectorTests

// swiftlint:disable all

@MainActor
@Suite("UserActivityDetectorTests")
final class UserActivityDetectorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    Container.shared.userInactivityTimeout.register { Self.timeoutInterval }

    timeoutNotificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { [weak self] _ in
      self?.timeoutNotificationCount += 1
    }

    let detector = UserActivityDetector()
    self.detector = detector
    EventInterceptor.eventHandler = { [weak detector] event in
      detector?.sendEvent(event)
    }
  }

  deinit {
    if let timeoutNotificationObserver {
      NotificationCenter.default.removeObserver(timeoutNotificationObserver)
    }
    EventInterceptor.resetEventHandlerForTesting()
    Container.shared.reset()
  }

  // MARK: Internal

  @Test
  func notificationIsSentOnTimeout() async {
    detector.sendEvent(UIEvent())

    try? await Task.sleep(nanoseconds: 300_000_000)

    #expect(timeoutNotificationCount == 1)
  }

  @Test
  func accessibilityFocusResetsTimer() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    try? await Task.sleep(nanoseconds: 250_000_000)
    #expect(timeoutNotificationCount == 0)

    try? await Task.sleep(nanoseconds: 150_000_000)
    #expect(timeoutNotificationCount == 1)
  }

  @Test
  func accessibilityFocusResetsTimerOnRepeat() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    try? await Task.sleep(nanoseconds: 300_000_000)
    #expect(timeoutNotificationCount == 0)

    try? await Task.sleep(nanoseconds: 150_000_000)
    #expect(timeoutNotificationCount == 1)
  }

  @Test
  func pauseNotificationPreventsTimeoutUntilResume() async {
    NotificationCenter.default.post(name: .pauseUserInactivityTimeout, object: nil)

    try? await Task.sleep(nanoseconds: 300_000_000)
    #expect(timeoutNotificationCount == 0)

    NotificationCenter.default.post(name: .resumeUserInactivityTimeout, object: nil)

    try? await Task.sleep(nanoseconds: 300_000_000)
    #expect(timeoutNotificationCount == 1)
  }

  @Test
  func disabledTimeoutNeverSchedulesNotification() async {
    NotificationCenter.default.post(name: .pauseUserInactivityTimeout, object: nil)
    if let timeoutNotificationObserver {
      NotificationCenter.default.removeObserver(timeoutNotificationObserver)
      self.timeoutNotificationObserver = nil
    }

    Container.shared.reset()
    Container.shared.userInactivityTimeout.register { .infinity }

    timeoutNotificationCount = 0
    timeoutNotificationObserver = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { [weak self] _ in
      self?.timeoutNotificationCount += 1
    }

    let detector = UserActivityDetector()
    self.detector = detector
    EventInterceptor.eventHandler = { [weak detector] event in
      detector?.sendEvent(event)
    }

    NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    detector.sendEvent(UIEvent())

    try? await Task.sleep(nanoseconds: 300_000_000)

    #expect(timeoutNotificationCount == 0)
  }

  @Test
  func applicationForegroundResetsTimerAfterBackground() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
      NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    try? await Task.sleep(nanoseconds: 250_000_000)
    #expect(timeoutNotificationCount == 0)

    try? await Task.sleep(nanoseconds: 350_000_000)
    #expect(timeoutNotificationCount == 1)
  }

  @Test
  func didLoginCloseResetsTimer() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(name: .didLoginClose, object: nil)
    }

    try? await Task.sleep(nanoseconds: 250_000_000)
    #expect(timeoutNotificationCount == 0)

    try? await Task.sleep(nanoseconds: 250_000_000)
    #expect(timeoutNotificationCount == 1)
  }

  @Test
  func interceptedApplicationEventIsForwardedToEventHandler() {
    let event = UIEvent()
    var receivedEvent: UIEvent?

    EventInterceptor.eventHandler = {
      receivedEvent = $0
    }

    EventInterceptor.handleInterceptedEvent(event)

    #expect(receivedEvent === event)
    EventInterceptor.resetEventHandlerForTesting()
  }

  // MARK: Private

  private static let timeoutInterval: TimeInterval = 0.2

  private var detector: UserActivityDetector!
  private var timeoutNotificationCount = 0
  private var timeoutNotificationObserver: NSObjectProtocol?

}
