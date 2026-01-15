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
  func identityCheck(caseId: String)
}


protocol EIDRequestInternalRoutes: ClosableRoutes, ExternalRoutes {

  var context: EIDRequestContext { get set }

}


protocol EIDRequestModule: AnyObject {
  var viewController: UIViewController { get }
  var router: EIDRequestRouter { get }
}

@MainActor
extension EIDRequestRoutes where Self: RouterProtocol {

  // MARK: Public

  public func eIDRequest() {
    let module = IntroductionModule()
    openModule(module)
  }

  public func autoVerification(caseId: String) {
    let module = AutoVerificationModule(caseId: caseId)
    openModule(module)
  }

  public func obtainConsent(caseId: String) {
    let module = LegalRepresentantConsentModule(caseId: caseId)
    openModule(module)
  }

  public func walletPairing(caseId: String) {
    let module = WalletPairingListModule(caseId: caseId)
    openModule(module)
  }

  public func identityCheck(caseId: String) {
    let module = AVIdentityCheckModule(caseId: caseId)
    openModule(module)
  }

  // MARK: Private

  private func openModule(_ module: EIDRequestModule, animated: Bool = true) {
    let viewController = module.viewController
    let style = ModalOpeningStyle(animatedWhenPresenting: animated, modalPresentationStyle: .fullScreen)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }

}
