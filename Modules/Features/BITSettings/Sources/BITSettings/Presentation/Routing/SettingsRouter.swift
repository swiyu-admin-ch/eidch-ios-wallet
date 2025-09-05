import BITNavigation
import SwiftUI

// MARK: - SettingsRouter

public final class SettingsRouter: Router<UIViewController> {}

@MainActor
extension SettingsRoutes where Self: RouterProtocol {
  public func settings() {
    let module = SettingsModule()
    let viewController = module.viewController
    let style = ModalOpeningStyle(modalPresentationStyle: .pageSheet)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }
}
