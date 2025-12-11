import Foundation
import SwiftUI
import UIKit

// MARK: - OpeningStyle

public protocol OpeningStyle: AnyObject {
  var viewController: UIViewController? { get set }

  func open(_ viewController: UIViewController)
  func close(_ viewController: UIViewController, _ onComplete: (() -> Void)?)

  func pop(_ viewController: UIViewController)
  func pop(_ viewController: UIViewController, count: Int)
  func popToRoot(_ viewController: UIViewController)
  func dismiss(_ viewController: UIViewController)
}

// MARK: - OpeningStyleAnimation

public protocol OpeningStyleAnimation: UIViewControllerAnimatedTransitioning {
  var isPresenting: Bool { get set }
}
