import BITCredentialShared
import Factory
import SwiftUI

@MainActor
class CredentialDetailModule {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, router: CredentialDetailRouter = Container.shared.credentialDetailRouter()) {
    self.router = router
    let viewController = UINavigationController(rootViewController: UIHostingController(rootView: CredentialDetailView(credential: credential, router: router)))
    router.viewController = viewController

    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  let router: CredentialDetailRouter
}
