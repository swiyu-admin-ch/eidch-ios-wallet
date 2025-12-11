import Foundation
import UIKit

extension UIApplication {

  // MARK: Public

  public static var topViewController: UIViewController? {
    guard
      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else
    {
      return nil
    }

    return findTopViewController(in: keyWindow.rootViewController)
  }

  // MARK: Private

  private static func findTopViewController(in viewController: UIViewController?) -> UIViewController? {
    if let presentedViewController = viewController?.presentedViewController {
      return findTopViewController(in: presentedViewController)
    }

    if let navigationController = viewController as? UINavigationController {
      return findTopViewController(in: navigationController.topViewController)
    }

    if
      let tabBarController = viewController as? UITabBarController,
      let selectedViewController = tabBarController.selectedViewController
    {
      return findTopViewController(in: selectedViewController)
    }

    return viewController
  }
}
