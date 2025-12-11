import BITCredentialShared
import Factory
import NavigatorUI
import SwiftUI

@MainActor
class CredentialDetailModule {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, router: CredentialDetailRouter = Container.shared.credentialDetailRouter()) {
    self.router = router
    let viewController = UIHostingController(rootView: ManagedNavigationStack {
      CredentialDetailView(credential: credential)
        .navigationDestination(CredentialDetailDestinations.self)
    })

    router.viewController = viewController

    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  let router: CredentialDetailRouter
}
