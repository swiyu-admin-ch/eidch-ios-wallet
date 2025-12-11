import Factory
import SwiftUI

@MainActor
class CameraPermissionModule {

  // MARK: Lifecycle

  init(router: InvitationRouter = Container.shared.invitationRouter(), delegate: InvitationDelegate? = nil) {
    self.router = router
    let viewController = UIHostingController(rootView: CameraPermissionView(router: router, delegate: delegate))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: InvitationRouter
}
