import Factory
import Foundation
import SwiftUI

@MainActor
public class VersionEnforcementModule {

  // MARK: Lifecycle

  public init(versionEnforcement: VersionEnforcement, router: VersionEnforcementRouter = Container.shared.versionEnforcementRouter()) {
    let router = router
    let viewModel = Container.shared.versionEnforcementViewModel((router, versionEnforcement))
    let viewController = UIHostingController(rootView: VersionEnforcementView(viewModel: viewModel))
    router.viewController = viewController

    self.router = router
    self.viewController = viewController
  }

  // MARK: Public

  public let viewController: UIViewController

  // MARK: Internal

  let router: VersionEnforcementRouter

}
