import BITCredentialShared
import Factory
import NavigatorUI
import SwiftUI

@MainActor
final class CredentialDetailModule {

  // MARK: Lifecycle

  init(credential: CredentialProtocol, delegate: CredentialDetailDelegate?, router: CredentialDetailRouter = Container.shared.credentialDetailRouter()) {
    self.router = router
    let viewController = UIHostingController(rootView: ManagedNavigationStack {
      CredentialDetailView(credential: credential, delegate: delegate)
        .navigationDestination(CredentialDetailDestinations.self)
    })

    router.viewController = viewController

    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  let router: CredentialDetailRouter
}
