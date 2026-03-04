import BITTheming
import Factory
import NavigatorUI
import SwiftUI

@MainActor
class LegalRepresentantConsentModule: EIDRequestModule {

  // MARK: Lifecycle

  init(router: EIDRequestRouter = Container.shared.eIDRequestRouter(), caseId: String) {
    self.router = router
    let viewController = UIHostingController(
      rootView:
      ManagedNavigationStack {
        EIDRequestDestinations.legalRepresentantConsent(caseId: caseId)
          .navigationDestination(EIDRequestDestinations.self)
      })
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: EIDRequestRouter
}
