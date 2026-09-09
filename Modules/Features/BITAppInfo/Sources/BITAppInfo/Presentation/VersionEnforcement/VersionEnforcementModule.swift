import Factory
import Foundation
import SwiftUI

@MainActor
public class VersionEnforcementModule {

  // MARK: Lifecycle

  public init(versionEnforcement: VersionEnforcement, delegate: VersionEnforcementDelegate, router: VersionEnforcementRouter = Container.shared.versionEnforcementRouter()) {
    let router = router
    let viewController = UIHostingController(rootView: VersionEnforcementView(router: router, versionEnforcement: versionEnforcement, delegate: delegate))
    router.viewController = viewController

    self.router = router
    self.viewController = viewController
  }

  // MARK: Public

  public let viewController: UIViewController

  // MARK: Internal

  let router: VersionEnforcementRouter

}
