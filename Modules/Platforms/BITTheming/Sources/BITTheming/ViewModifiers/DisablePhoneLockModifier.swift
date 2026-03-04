import SwiftUI
import UIKit

// MARK: - DisablePhoneLock

public struct DisablePhoneLock: ViewModifier {
  public init() {}

  public func body(content: Content) -> some View {
    content
      .onAppear {
        UIApplication.shared.isIdleTimerDisabled = true
      }
      .onDisappear {
        UIApplication.shared.isIdleTimerDisabled = false
      }
  }
}

extension View {
  public func disablePhoneLock() -> some View {
    modifier(DisablePhoneLock())
  }
}
