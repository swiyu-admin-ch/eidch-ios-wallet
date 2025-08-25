import Factory
import Foundation
import SwiftUI
import UIKit

@MainActor
class SplashScreenModule {

  // MARK: Lifecycle

  init(router: RootRouter = Container.shared.splashScreenRouter(), completed: @escaping () -> Void = {}) {
    let router = router

    var viewController: UIViewController
    if #available(iOS 17.0, *) {
      let view = AnimatedSplashScreen(completed: {
        router.close()
        completed()
      })
      viewController = UIHostingController(rootView: view)
    } else {
      let view = SplashScreen(completed: {
        router.close()
        completed()
      })
      viewController = UIHostingController(rootView: view)
    }

    router.viewController = viewController

    self.router = router
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController

  let router: RootRouter

}
