import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

@MainActor
class AutoVerificationModule {

  // MARK: Lifecycle

  init(caseId: String, router: EIDRequestRouter = Container.shared.eIDRequestRouter(), navigatorRoot: Navigator = Container.shared.navigatorRoot()) {
    self.router = router

    let viewController = UIHostingController(rootView: ManagedNavigationStack {
      AVWelcomeView()
    }
    .navigationDestination(EIDRequestDestinations.self)
    .navigationRoot(navigatorRoot))
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
