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

// swiftlint:disable implicitly_unwrapped_optional

@MainActor
@Suite("UserActivityDetectorTests", .serialized)
final class UserActivityDetectorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    Container.shared.userInactivityTimeout.register { Self.timeoutInterval }

    let detector = UserActivityDetector()
    self.detector = detector
    EventInterceptor.eventHandler = { [weak detector] event in
      detector?.sendEvent(event)
    }
  }

  isolated deinit {
    EventInterceptor.resetEventHandlerForTesting()
    Container.shared.reset()
  }

  // MARK: Internal

  @Test
  func notificationIsSentOnTimeout() async {
    detector.sendEvent(UIEvent())

    await expectTimeoutNotifications(1, within: 300_000_000)
  }

  @Test
  func accessibilityFocusResetsTimer() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    await expectTimeoutNotifications(0, within: 250_000_000)
    await expectTimeoutNotifications(1, within: 150_000_000)
  }

  @Test
  func accessibilityFocusResetsTimerOnRepeat() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
      NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    }

    await expectTimeoutNotifications(0, within: 300_000_000)
    await expectTimeoutNotifications(1, within: 150_000_000)
  }

  @Test
  func pauseNotificationPreventsTimeoutUntilResume() async {
    NotificationCenter.default.post(name: .pauseUserInactivityTimeout, object: nil)

    await expectTimeoutNotifications(0, within: 300_000_000)

    NotificationCenter.default.post(name: .resumeUserInactivityTimeout, object: nil)

    await expectTimeoutNotifications(1, within: 300_000_000)
  }

  @Test
  func disabledTimeoutNeverSchedulesNotification() async {
    NotificationCenter.default.post(name: .pauseUserInactivityTimeout, object: nil)

    Container.shared.reset()
    Container.shared.userInactivityTimeout.register { .infinity }

    let detector = UserActivityDetector()
    self.detector = detector
    EventInterceptor.eventHandler = { [weak detector] event in
      detector?.sendEvent(event)
    }

    NotificationCenter.default.post(name: UIAccessibility.elementFocusedNotification, object: nil)
    detector.sendEvent(UIEvent())

    await expectTimeoutNotifications(0, within: 300_000_000)
  }

  @Test
  func applicationForegroundResetsTimerAfterBackground() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
      NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    await expectTimeoutNotifications(0, within: 250_000_000)
    await expectTimeoutNotifications(1, within: 350_000_000)
  }

  @Test
  func didLoginCloseResetsTimer() async {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(name: .didLoginClose, object: nil)
    }

    await expectTimeoutNotifications(0, within: 250_000_000)
    await expectTimeoutNotifications(1, within: 250_000_000)
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

  private nonisolated static let timeoutInterval: TimeInterval = 0.2

  private var detector: UserActivityDetector!

  /// Observes `.userInactivityTimeout` for the given duration and confirms it is posted exactly `count` times.
  /// The detector posts the notification synchronously on the main actor, so the count is settled once the wait ends.
  private func expectTimeoutNotifications(_ count: Int, within nanoseconds: UInt64) async {
    await confirmation("userInactivityTimeout posted", expectedCount: count) { timedOut in
      let observer = NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: nil) { _ in
        timedOut()
      }
      defer {
        NotificationCenter.default.removeObserver(observer)
      }
      try? await Task.sleep(nanoseconds: nanoseconds)
    }
  }
}
