import Factory
import Foundation
import SwiftUI
import UIKit

@MainActor
class SplashScreenModule {

  // MARK: Lifecycle

  init(router: RootRouter = Container.shared.splashScreenRouter(), completed: @escaping () -> Void = {}) {
    let router = router

    let view = AnimatedSplashScreen(completed: {
      router.close()
      completed()
    })
    let viewController = UIHostingController(rootView: view)

    router.viewController = viewController

    self.router = router
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController

  let router: RootRouter

}
