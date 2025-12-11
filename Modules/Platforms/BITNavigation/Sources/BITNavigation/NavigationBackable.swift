import NavigatorUI
import SwiftUI

// MARK: - NavigationBackable

@MainActor
public protocol NavigationBackable: ObservableObject {
  var isNavigationBackTriggered: Bool { get set }
  func navigationBack()
}

extension NavigationBackable {
  public func navigationBack() {
    isNavigationBackTriggered = true
  }
}

// MARK: - NavigationBackableModifier

public struct NavigationBackableModifier: ViewModifier {
  @Binding var bindingValue: Bool
  @Environment(\.navigator) var navigator

  public func body(content: Content) -> some View {
    content
      .onChange(of: bindingValue) { newValue in
        if newValue {
          navigator.pop()
        }
      }
  }
}

extension View {
  public func navigationBack(onChangeOf value: Binding<Bool>) -> some View {
    modifier(NavigationBackableModifier(bindingValue: value))
  }
}
