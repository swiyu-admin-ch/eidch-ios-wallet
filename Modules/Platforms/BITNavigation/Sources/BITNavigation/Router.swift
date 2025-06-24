import Foundation
import SwiftUI
import UIKit

// MARK: - Router

open class Router<VC>: RouterProtocol where VC: UIViewController {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public typealias View = VC

  public weak var viewController: VC?
  public var current: OpeningStyle?

  public func open(_ viewController: UIViewController, on parentViewController: UIViewController? = nil, as style: OpeningStyle) {
    current = style
    current?.viewController = parentViewController ?? self.viewController
    current?.open(viewController)
  }

  public func close(onComplete: (() -> Void)? = nil) {
    guard let current, let viewController else { return }
    current.close(viewController, onComplete)
  }

  public func close() {
    close(onComplete: nil)
  }

  public func pop() {
    guard let current, let viewController else { return }
    current.pop(viewController)
  }

  public func pop(number: Int) {
    guard let current, let viewController else { return }
    current.pop(viewController, number: number)
  }

  public func popToRoot() {
    guard let current, let viewController else { return }
    current.popToRoot(viewController)
  }

  public func dismiss() {
    guard let current, let viewController else { return }
    current.dismiss(viewController)
  }

}
