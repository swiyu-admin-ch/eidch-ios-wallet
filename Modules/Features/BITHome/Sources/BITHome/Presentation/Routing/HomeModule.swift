import BITNavigation
import Factory
import SwiftUI

// MARK: - HomeModule

@MainActor
public class HomeModule {

  // MARK: Lifecycle

  public init(router: Router<UIViewController> & HomeRouterRoutes = Container.shared.homeRouter()) {
    let view = HomeView(router: router)
      .environment(\.font, .custom.body)
      .preferredColorScheme(.light)
    let viewController = HomeHostingController(rootView: view)
    let navigation = UINavigationController(rootViewController: viewController)
    router.viewController = navigation

    self.viewController = navigation
  }

  // MARK: Public

  public let viewController: UIViewController
}
