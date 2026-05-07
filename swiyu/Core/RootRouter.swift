import BITAppAuth
import BITInvitation
import BITNavigation
import BITOnboarding
import Factory
import Foundation
import UIKit

// MARK: - RootRouterRoutes

protocol RootRouterRoutes: AppRoutes, LoginRoutes {}

// MARK: - RootRouter

final class RootRouter: Router<UIViewController>, RootRouterRoutes {}

// MARK: - AppRoutes

protocol AppRoutes {
  func splashScreen(_ completed: @escaping () -> Void)
}

// MARK: - AppRoutes

@MainActor
extension AppRoutes where Self: RouterProtocol {
  func splashScreen(_ completed: @escaping () -> Void) {
    let module = Container.shared.splashScreenModule(completed)
    let style = ModalOpeningStyle(animatedWhenPresenting: false, modalPresentationStyle: .fullScreen)
    module.router.current = style
    let viewController = module.viewController
    open(viewController, on: UIApplication.topViewController, as: style)
  }
}
