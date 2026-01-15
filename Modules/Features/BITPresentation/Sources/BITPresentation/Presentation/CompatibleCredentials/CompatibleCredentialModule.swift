import Factory
import Foundation
import SwiftUI

final class CompatibleCredentialsModule: PresentationModuleProtocol {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationRouter = Container.shared.presentationRouter()) {
    self.router = router

    let viewController = UIHostingController(rootView: CompatibleCredentialView(context: context, router: router))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: PresentationRouter
}
