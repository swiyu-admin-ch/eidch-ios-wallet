import BITNavigation
import BITTheming
import SwiftUI


public protocol EIDRequestRoutes {
  func eIDRequest()
  func autoVerification()
}


protocol EIDRequestInternalRoutes: ClosableRoutes, ExternalRoutes {
  func dataPrivacy()
  func checkCardIntroduction()
  func cameraPermission()
  func mrzScanner()
  func queueInformation(_ onlineSessionStartDate: Date)
  func legalRepresentant()
  func legalRepresentantConsent(caseId: String)
  func legalRepresentantQRCode(caseId: String)
}

extension EIDRequestInternalRoutes where Self: RouterProtocol {

  func dataPrivacy() {
    let viewController = UIHostingController(rootView: DataPrivacyView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func checkCardIntroduction() {
    let viewController = UIHostingController(rootView: CheckCardIntroductionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func cameraPermission() {
    let viewController = UIHostingController(rootView: CameraPermissionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func mrzScanner() {
    let viewController = HideBackButtonHostingController(rootView: MRZScannerView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func queueInformation(_ onlineSessionStartDate: Date) {
    let viewController = HideBackButtonHostingController(rootView: QueueInformationView(router: self, onlineSessionStartDate: onlineSessionStartDate))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func legalRepresentant() {
    let viewController = UIHostingController(rootView: LegalRepresentantView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func legalRepresentantConsent(caseId: String) {
    let viewController = UIHostingController(rootView: LegalRepresentantConsentView(router: self, caseId: caseId))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func legalRepresentantQRCode(caseId: String) {
    let viewController = UIHostingController(rootView: LegalRepresentantQRCodeView(router: self, caseId: caseId))
    open(viewController, as: NavigationPushOpeningStyle())
  }
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

  public func autoVerification() {
    let module = AutoVerificationModule()
    let viewController = module.viewController
    let style = ModalOpeningStyle(animatedWhenPresenting: true, modalPresentationStyle: .fullScreen)

    module.router.current = style
    open(viewController, on: self.viewController, as: style)
  }
}
