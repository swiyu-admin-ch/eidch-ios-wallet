import BITAVWrapper
import BITNavigation
import BITPresentation
import BITTheming
import SwiftUI


public protocol EIDRequestRoutes {
  func eIDRequest()
  func autoVerification(caseId: String)
  func obtainConsent(caseId: String)
  func walletPairing(caseId: String)
}


protocol EIDRequestInternalRoutes: ClosableRoutes, ExternalRoutes {

  var context: EIDRequestContext { get set }

}

@MainActor
extension EIDRequestRoutes where Self: RouterProtocol {

  public func eIDRequest() {
    let module = IntroductionModule()
    let viewController = module.viewController
    let style = ModalOpeningStyle(animatedWhenPresenting: true, modalPresentationStyle: .fullScreen)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }

  public func autoVerification(caseId: String) {
    let module = AutoVerificationModule(caseId: caseId)
    let viewController = module.viewController
    let style = ModalOpeningStyle(animatedWhenPresenting: true, modalPresentationStyle: .fullScreen)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }

  public func obtainConsent(caseId: String) {
    let module = LegalRepresentantConsentModule(caseId: caseId)
    let viewController = module.viewController
    let style = ModalOpeningStyle(animatedWhenPresenting: true, modalPresentationStyle: .fullScreen)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }

  public func walletPairing(caseId: String) {
    let module = WalletPairingListModule(caseId: caseId)
    let viewController = module.viewController
    let style = ModalOpeningStyle(animatedWhenPresenting: true, modalPresentationStyle: .fullScreen)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }
}
