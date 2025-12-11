import BITCredentialShared
import BITNavigation
import Factory
import SwiftUI

// MARK: - CredentialDetailRouter

final class CredentialDetailRouter: Router<UIViewController> { }

@MainActor
extension CredentialDetailRoutes where Self: RouterProtocol {

  public func credentialDetail(_ credential: VerifiableCredential) {
    let module = Container.shared.credentialDetailModule(credential)
    let style = ModalOpeningStyle(animated: true, modalPresentationStyle: .fullScreen)
    module.router.current = style

    let viewController = module.viewController
    open(viewController, on: self.viewController, as: style)
  }
}
