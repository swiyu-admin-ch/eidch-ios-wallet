import BITTheming
import Factory
import SwiftUI

@MainActor
class AutoVerificationModule {

  // MARK: Lifecycle

  init(router: EIDRequestRouter = Container.shared.eIDRequestRouter()) {
    self.router = router
    let viewController = UIHostingController(rootView: AVWelcomeView(router: router))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: EIDRequestRouter
}
