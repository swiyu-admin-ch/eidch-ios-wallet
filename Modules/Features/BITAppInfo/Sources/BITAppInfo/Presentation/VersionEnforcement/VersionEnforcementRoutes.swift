import BITNavigation
import Factory
import Foundation
import Spyable

// MARK: - VersionEnforcementRoutes

@Spyable
public protocol VersionEnforcementRoutes {
  func versionEnforcement(_ versionEnforcement: VersionEnforcement)
}

// MARK: - VersionEnforcementRoutes

extension VersionEnforcementRoutes where Self: RouterProtocol {

  @MainActor
  public func versionEnforcement(_ versionEnforcement: VersionEnforcement) {
    let module = Container.shared.versionEnforcementModule(versionEnforcement)
    let style = ModalOpeningStyle(animatedWhenPresenting: true, modalPresentationStyle: .fullScreen)
    module.router.current = style

    open(module.viewController, as: style)
  }
}
