import Factory
import NavigatorUI
import SwiftUI

@MainActor
class IntroductionModule: EIDRequestModule {

  // MARK: Lifecycle

  init(router: EIDRequestRouter = Container.shared.eIDRequestRouter()) {
    self.router = router
    let viewController = UIHostingController(rootView: ManagedNavigationStack {
      EIDRequestDestinations.introduction()
        .navigationDestination(EIDRequestDestinations.self)
    })
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: EIDRequestRouter
}
