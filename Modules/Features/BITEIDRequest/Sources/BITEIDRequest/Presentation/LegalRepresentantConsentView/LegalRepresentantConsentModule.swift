import BITTheming
import Factory
import SwiftUI

@MainActor
class LegalRepresentantConsentModule {

  // MARK: Lifecycle

  init(router: EIDRequestRouter = Container.shared.eIDRequestRouter(), caseId: String) {
    self.router = router
    let viewController = UINavigationController(rootViewController: HideBackButtonHostingController(rootView: LegalRepresentantConsentView(router: router, caseId: caseId)))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: EIDRequestRouter
}
