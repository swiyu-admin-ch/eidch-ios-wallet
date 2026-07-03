import BITL10n
import Factory
import Foundation
import UIKit

@Observable
class VersionEnforcementViewModel {

  // MARK: Lifecycle

  init(router: VersionEnforcementRouterRoutes = Container.shared.versionEnforcementRouter(), versionEnforcement: VersionEnforcement, delegate: VersionEnforcementDelegate) {
    self.router = router
    self.versionEnforcement = versionEnforcement
    self.delegate = delegate
  }

  // MARK: Internal

  var enforcementType: VersionEnforcementType {
    versionEnforcement.type
  }

  var message: VersionEnforcement.Message? {
    versionEnforcement.messages.findDisplayWithFallback()
  }

  func dismissToHomeScreen() {
    router.close(onComplete: delegate?.didDismissVersionEnforcement)
  }

  // MARK: Private

  private let router: VersionEnforcementRouterRoutes
  private let versionEnforcement: VersionEnforcement

  private weak var delegate: VersionEnforcementDelegate?
}
