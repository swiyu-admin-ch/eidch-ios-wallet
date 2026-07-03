import SwiftUI

extension AnyTransition {
  public static var push: AnyTransition {
    asymmetric(
      insertion: .identity,
      removal: .push(from: .trailing)).combined(with: .opacity)
  }
}
