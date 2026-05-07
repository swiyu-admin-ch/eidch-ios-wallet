import BITCore
import SwiftUI

// MARK: - InactivityTimeoutModifier

struct InactivityTimeoutModifier: ViewModifier {

  // MARK: Internal

  func body(content: Content) -> some View {
    content
      .onAppear {
        NotificationCenter.default.post(name: .pauseUserInactivityTimeout, object: nil)
      }
      .onDisappear {
        NotificationCenter.default.post(name: .resumeUserInactivityTimeout, object: nil)
      }
  }
}

// MARK: - View Extension

extension View {
  public func suspendInactivityTimeout() -> some View {
    modifier(InactivityTimeoutModifier())
  }
}
