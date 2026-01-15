import Factory
import Foundation
import SwiftUI

final class PresentationRequestReviewModule: PresentationModuleProtocol {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationRouter = Container.shared.presentationRouter()) {
    self.router = router

    let view = PresentationRequestReviewView(context: context, router: router)

    let viewController = UIHostingController(rootView: view)
    router.viewController = viewController
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: PresentationRouter
}
