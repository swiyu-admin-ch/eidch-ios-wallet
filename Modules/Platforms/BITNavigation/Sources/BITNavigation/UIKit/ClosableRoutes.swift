import Foundation
import Spyable

// MARK: - ClosableRoutes

@Spyable
@MainActor
public protocol ClosableRoutes: AnyObject {
  func close(onComplete: (() -> Void)?)
  func close()
  func pop()
  func pop(count: Int)
  func popToRoot()
  func dismiss()
}
