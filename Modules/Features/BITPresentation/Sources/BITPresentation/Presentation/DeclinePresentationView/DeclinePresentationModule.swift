import BITNavigation
import Factory
import SwiftUI

final class DeclinePresentationModule: PresentationModuleProtocol {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationRouter = Container.shared.presentationRouter()) {
    self.router = router

    let viewController = UIHostingController(rootView: DeclinePresentationView(context: context, router: router))
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: PresentationRouter
}
