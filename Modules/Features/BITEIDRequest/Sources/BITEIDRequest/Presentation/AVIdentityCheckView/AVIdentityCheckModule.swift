import BITTheming
import Factory
import NavigatorUI
import SwiftUI

@MainActor
class AVIdentityCheckModule: EIDRequestModule {

  // MARK: Lifecycle

  init(router: EIDRequestRouter = Container.shared.eIDRequestRouter(), caseId: String) {
    self.router = router
    let viewController = UIHostingController(rootView:
      ManagedNavigationStack {
        EIDRequestDestinations.avIdentityCheck
          .navigationDestination(EIDRequestDestinations.self)
      })
    router.viewController = viewController
    self.viewController = viewController

    context.caseId = caseId
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: EIDRequestRouter

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
}
