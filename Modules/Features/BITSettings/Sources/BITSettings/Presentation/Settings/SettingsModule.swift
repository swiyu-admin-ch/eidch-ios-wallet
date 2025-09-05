import Factory
import SwiftUI

@MainActor
class SettingsModule {

  // MARK: Lifecycle

  init(router: SettingsRouter = Container.shared.settingsRouter()) {
    self.router = router
    let viewController = UIHostingController(rootView: SettingsView())
    self.viewController = viewController
  }

  // MARK: Internal

  let viewController: UIViewController
  var router: SettingsRouter
}
