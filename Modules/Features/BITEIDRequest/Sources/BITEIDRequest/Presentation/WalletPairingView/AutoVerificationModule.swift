import BITTheming
import Factory
import SwiftUI

@MainActor
class AutoVerificationModule {

  // MARK: Lifecycle

  init(caseId: String, router: EIDRequestRouter = Container.shared.eIDRequestRouter()) {
    self.router = router
    self.router.context.caseId = caseId

    let viewController = UIHostingController(rootView: AVWelcomeView(router: router))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: EIDRequestRouter
}
