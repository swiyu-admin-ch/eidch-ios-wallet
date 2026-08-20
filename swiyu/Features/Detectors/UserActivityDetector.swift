import BITCore
import Factory
import UIKit

// MARK: - UserActivityDetector

final class UserActivityDetector {

  // MARK: Lifecycle

  init() {
    resetInactivityTimer()
    observeAccessibilityFocus()
    observeApplicationLifecycle()
    observeSuspensionNotifications()
    observeWindowActivity()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: Internal

  func sendEvent(_ event: UIEvent) {
    if eventContainsUserInteraction(event) {
      resetInactivityTimer()
    }
  }

  // MARK: Private

  private var inactivityTimer: Timer?
  @Injected(\.userInactivityTimeout) private var timeoutInterval
  private var suspensionCount = 0

  private var isSuspended: Bool {
    suspensionCount > 0
  }

  private func eventContainsUserInteraction(_ event: UIEvent) -> Bool {
    if let touches = event.allTouches, touches.contains(where: { $0.phase == .began }) {
      return true
    }

    if let pressesEvent = event as? UIPressesEvent {
      let presses = pressesEvent.allPresses
      if presses.contains(where: { $0.phase == .began }) {
        return true
      }
    }

    return false
  }

  private func observeAccessibilityFocus() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAccessibilityFocus),
      name: UIAccessibility.elementFocusedNotification,
      object: nil)
  }

  private func observeApplicationLifecycle() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleApplicationWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleApplicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleApplicationDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleApplicationWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidLoginClose),
      name: .didLoginClose,
      object: nil)
  }

  private func observeSuspensionNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handlePauseInactivityTimeout),
      name: .pauseUserInactivityTimeout,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleResumeInactivityTimeout),
      name: .resumeUserInactivityTimeout,
      object: nil)
  }

  private func observeWindowActivity() {
    let names: [Notification.Name] = [
      UIFocusSystem.didUpdateNotification,
      .windowDidUpdateFocus,
      .windowPressesBegan,
    ]

    for name in names {
      NotificationCenter.default
        .addObserver(
          self,
          selector: #selector(handleWindowActivity),
          name: name,
          object: nil)
    }
  }

  @objc
  nonisolated private func handleAccessibilityFocus() {
    Task { @MainActor [weak self] in
      guard let self, !isSuspended else { return }
      resetInactivityTimer()
    }
  }

  @objc
  nonisolated private func handleApplicationWillResignActive() {
    Task { @MainActor [weak self] in
      self?.invalidateInactivityTimer()
    }
  }

  @objc
  nonisolated private func handleApplicationDidBecomeActive() {
    Task { @MainActor [weak self] in
      guard let self, !isSuspended else { return }
      resetInactivityTimer()
    }
  }

  @objc
  nonisolated private func handleApplicationDidEnterBackground() {
    Task { @MainActor [weak self] in
      self?.invalidateInactivityTimer()
    }
  }

  @objc
  nonisolated private func handleApplicationWillEnterForeground() {
    Task { @MainActor [weak self] in
      guard let self, !isSuspended else { return }
      resetInactivityTimer()
    }
  }

  @objc
  nonisolated private func handleDidLoginClose() {
    Task { @MainActor [weak self] in
      guard let self, !isSuspended else { return }
      resetInactivityTimer()
    }
  }

  @objc
  nonisolated private func handlePauseInactivityTimeout() {
    Task { @MainActor [weak self] in
      self?.pauseInactivityTimeout()
    }
  }

  @objc
  nonisolated private func handleResumeInactivityTimeout() {
    Task { @MainActor [weak self] in
      self?.resumeInactivityTimeout()
    }
  }

  private func pauseInactivityTimeout() {
    suspensionCount += 1
    invalidateInactivityTimer()
  }

  private func resumeInactivityTimeout() {
    suspensionCount = max(0, suspensionCount - 1)

    guard !isSuspended else { return }
    resetInactivityTimer()
  }

  private func invalidateInactivityTimer() {
    inactivityTimer?.invalidate()
    inactivityTimer = nil
  }

  private func resetInactivityTimer() {
    guard !isSuspended else { return }

    invalidateInactivityTimer()
    guard timeoutInterval.isFinite, timeoutInterval > 0 else { return }

    inactivityTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false, block: { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.onTimeout()
      }
    })
  }

  private func onTimeout() {
    NotificationCenter.default.post(name: .userInactivityTimeout, object: nil)
  }

  @objc
  private func handleWindowActivity() {
    guard !isSuspended else { return }
    resetInactivityTimer()
  }
}
