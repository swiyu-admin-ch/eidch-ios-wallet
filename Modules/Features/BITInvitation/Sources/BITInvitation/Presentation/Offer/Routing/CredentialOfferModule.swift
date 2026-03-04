import BITCredential
import BITCredentialShared
import Factory
import SwiftUI

@MainActor
class CredentialOfferModule {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, trustInformation: TrustInformation?, router: CredentialOfferRouter = Container.shared.credentialOfferRouter(), delegate: InvitationDelegate?) {
    self.router = router
    let viewController = UIHostingController(rootView: CredentialOfferView(credential: credential, trustInformation: trustInformation, router: router, delegate: delegate))
    router.viewController = viewController

    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIHostingController<CredentialOfferView>
  let router: CredentialOfferRouter
}
