import BITNavigation
import Factory
import Foundation
import UIKit

// MARK: - LoginModule

@MainActor
public class LoginModule {

  // MARK: Lifecycle

  public init(router: LoginRouter = Container.shared.loginRouter()) {
    let router = router
    let viewModel = Container.shared.loginViewModel(router)
    let viewController = LoginHostingController(rootView: LoginView(viewModel: viewModel))
    let navigation = UINavigationController(rootViewController: viewController)
    router.viewController = navigation

    self.router = router
    self.viewController = navigation
    self.viewModel = viewModel
  }

  // MARK: Public

  public let viewController: UIViewController

  public func configureForOverlayPresentation() {
    let style = LoginOverlayOpeningStyle()
    style.viewController = viewController
    router.current = style
  }

  // MARK: Internal

  let router: LoginRouter
  let viewModel: LoginViewModel

}

// MARK: - LoginOverlayOpeningStyle

private final class LoginOverlayOpeningStyle: OpeningStyle {

  weak var viewController: UIViewController?

  func open(_ viewController: UIViewController) {}

  func close(_ viewController: UIViewController, _ onComplete: (() -> Void)?) {
    onComplete?()
  }

  func pop(_ viewController: UIViewController) {
    close(viewController, nil)
  }

  func pop(_ viewController: UIViewController, count: Int) {
    close(viewController, nil)
  }

  func popToRoot(_ viewController: UIViewController) {
    close(viewController, nil)
  }

  func dismiss(_ viewController: UIViewController) {
    close(viewController, nil)
  }
}
