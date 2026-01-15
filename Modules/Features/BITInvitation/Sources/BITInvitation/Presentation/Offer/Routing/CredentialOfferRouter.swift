import BITCredential
import BITCredentialShared
import BITNavigation
import Factory
import SwiftUI

// MARK: - CredentialOfferRouter

final class CredentialOfferRouter: Router<UIViewController>, CredentialOfferInternalRoutes {}

@MainActor
extension CredentialOfferRoutes where Self: RouterProtocol {

  public func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation? = nil) {
    let module = Container.shared.credentialOfferModule((credential, trustInformation))
    let style = NavigationPushOpeningStyle()
    module.router.current = style

    let viewController = module.viewController
    open(viewController, on: self.viewController, as: style)
  }
}

extension CredentialOfferInternalRoutes where Self: RouterProtocol {

  func wrongData() {
    let viewController = UINavigationController(rootViewController: UIHostingController(rootView: CredentialOfferWrongDataView(router: self)))
    open(viewController, as: ModalOpeningStyle(animatedWhenPresenting: true))
  }

  func badgeInformation(badgeType: BadgeType) {
    let view = BadgeInformationView(badgeType: badgeType) { [weak self] in
      self?.dismiss()
    }
    let viewController = UINavigationController(rootViewController: UIHostingController(rootView: view))
    open(viewController, as: ModalOpeningStyle(animatedWhenPresenting: true))
  }
}
