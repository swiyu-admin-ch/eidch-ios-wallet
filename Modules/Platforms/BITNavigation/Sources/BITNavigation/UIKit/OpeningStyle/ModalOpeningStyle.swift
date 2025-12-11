import Foundation
import UIKit

// MARK: - ModalOpeningStyle

public class ModalOpeningStyle: NSObject {

  // MARK: Lifecycle

  public init(
    animation: OpeningStyleAnimation? = nil,
    animated: Bool = true,
    modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
    modalPresentationStyle: UIModalPresentationStyle = .automatic)
  {
    self.animation = animation
    animatedWhenPresenting = animated
    animatedWhenClosing = animated
    self.modalTransitionStyle = modalTransitionStyle
    self.modalPresentationStyle = modalPresentationStyle
  }

  public init(
    animation: OpeningStyleAnimation? = nil,
    animatedWhenPresenting: Bool = true,
    animatedWhenClosing: Bool = true,
    modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
    modalPresentationStyle: UIModalPresentationStyle = .automatic)
  {
    self.animation = animation
    self.animatedWhenPresenting = animatedWhenPresenting
    self.animatedWhenClosing = animatedWhenClosing
    self.modalTransitionStyle = modalTransitionStyle
    self.modalPresentationStyle = modalPresentationStyle
  }

  // MARK: Public

  public weak var viewController: UIViewController?
  public var completionHandler: (() -> Void)?

  // MARK: Internal

  var animation: OpeningStyleAnimation?
  var animatedWhenPresenting = true
  var animatedWhenClosing = true

  var modalTransitionStyle: UIModalTransitionStyle
  var modalPresentationStyle: UIModalPresentationStyle

}

// MARK: OpeningStyle

extension ModalOpeningStyle: OpeningStyle {

  public func open(_ viewController: UIViewController) {
    viewController.transitioningDelegate = self
    viewController.modalTransitionStyle = modalTransitionStyle
    viewController.modalPresentationStyle = modalPresentationStyle

    self.viewController?.present(viewController, animated: animatedWhenPresenting, completion: completionHandler)
  }

  public func close(_ viewController: UIViewController, _ onComplete: (() -> Void)?) {
    viewController.dismiss(animated: animatedWhenClosing, completion: onComplete)
  }

  public func dismiss(_ viewController: UIViewController) {
    close(viewController, nil)
  }

  public func pop(_ viewController: UIViewController) {
    close(viewController, nil)
  }

  public func pop(_ viewController: UIViewController, count: Int) {
    close(viewController, nil)
  }

  public func popToRoot(_ viewController: UIViewController) {
    close(viewController, nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate

extension ModalOpeningStyle: UIViewControllerTransitioningDelegate {

  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController)
    -> UIViewControllerAnimatedTransitioning?
  {
    guard let animation else {
      return nil
    }
    animation.isPresenting = true
    return animation
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard let animation else {
      return nil
    }
    animation.isPresenting = false
    return animation
  }
}
