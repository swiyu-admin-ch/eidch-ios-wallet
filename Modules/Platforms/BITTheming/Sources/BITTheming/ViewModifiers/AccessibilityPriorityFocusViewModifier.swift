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
  }

  // MARK: Private

  @AccessibilityFocusState private var isFocused: Bool

  private let delay: Duration

  @MainActor
  private func setFocus() async {
    isFocused = false
    try? await Task.sleep(for: delay)
    isFocused = true
  }
}

// MARK: - View Extension

extension View {
  public func accessibilityPriorityFocus(delay: Duration = .milliseconds(450)) -> some View {
    modifier(AccessibilityPriorityFocusViewModifier(delay: delay))
  }
}
