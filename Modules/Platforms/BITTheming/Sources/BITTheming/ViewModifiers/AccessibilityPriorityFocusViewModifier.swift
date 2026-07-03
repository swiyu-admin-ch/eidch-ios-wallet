import SwiftUI

// MARK: - AccessibilityPriorityFocusViewModifier

struct AccessibilityPriorityFocusViewModifier: ViewModifier {

  // MARK: Lifecycle

  init(delay: Duration) {
    self.delay = delay
  }

  // MARK: Internal

  func body(content: Content) -> some View {
    content
      .accessibilityFocused($isFocused)
      .task {
        await setFocus()
      }
      .onAppear {
        observeSystemPermissionAlert()
      }
      .onDisappear {
        cancelSystemPermissionAlertObservation()
      }
  }

  // MARK: Private

  @AccessibilityFocusState private var isFocused: Bool
  @State private var permissionAlertPresentedTask: Task<Void, Never>?
  @State private var permissionAlertFinishedTask: Task<Void, Never>?

  private let delay: Duration

  @MainActor
  private func setFocus() async {
    isFocused = false
    try? await Task.sleep(for: delay)
    isFocused = true
  }

  private func observeSystemPermissionAlert() {
    permissionAlertPresentedTask = observationTask(for: .permissionAlertPresented, isFocused: false)
    permissionAlertFinishedTask = observationTask(for: .permissionAlertFinished, isFocused: true)
  }

  private func cancelSystemPermissionAlertObservation() {
    permissionAlertPresentedTask?.cancel()
    permissionAlertFinishedTask?.cancel()
  }

  private func observationTask(for notificationName: Foundation.Notification.Name, isFocused: Bool) -> Task<Void, Never> {
    Task {
      for await _ in NotificationCenter.default.notifications(named: notificationName) {
        self.isFocused = isFocused
      }
    }
  }
}

// MARK: - View Extension

extension View {
  public func accessibilityPriorityFocus(delay: Duration = .milliseconds(450)) -> some View {
    modifier(AccessibilityPriorityFocusViewModifier(delay: delay))
  }
}
