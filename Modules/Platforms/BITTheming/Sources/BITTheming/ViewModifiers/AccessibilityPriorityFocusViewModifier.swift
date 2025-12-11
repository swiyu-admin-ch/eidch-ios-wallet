import SwiftUI

// MARK: - AccessibilityPriorityFocusViewModifier

struct AccessibilityPriorityFocusViewModifier: ViewModifier {

  // MARK: Internal

  func body(content: Content) -> some View {
    content
      .accessibilityFocused($isPriorityFocus)
      .onAppear {
        setFocus()
      }
  }

  // MARK: Private

  @AccessibilityFocusState private var isPriorityFocus: Bool

  private func setFocus() {
    DispatchQueue.main.async {
      isPriorityFocus = false
      isPriorityFocus = true
    }
  }
}

// MARK: - View Extension

extension View {
  public func accessibilityPriorityFocus() -> some View {
    modifier(AccessibilityPriorityFocusViewModifier())
  }
}
