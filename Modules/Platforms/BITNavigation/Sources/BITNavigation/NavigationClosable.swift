import SwiftUI

// MARK: - NavigationClosable

@MainActor
public protocol NavigationClosable: ObservableObject {
  var isNavigationCloseTriggered: Bool { get set }
  func navigationClose()
}

extension NavigationClosable {
  public func navigationClose() {
    isNavigationCloseTriggered = true
  }
}
