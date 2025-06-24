import BITNavigation
import BITTheming
import SwiftUI


public protocol EIDRequestRoutes {
  func eIDRequest()
  func autoVerification()
  func obtainConsent(caseId: String)
}


protocol EIDRequestInternalRoutes: ClosableRoutes, ExternalRoutes {

  var context: EIDRequestContext { get set }

  func dataPrivacy()
  func cameraPermission()
  func mrzScanner()
  func queueInformation(_ onlineSessionStartDate: Date)
  func legalRepresentant()
  func legalRepresentantConsent(caseId: String)
  func legalRepresentantQRCode(caseId: String)
  func legalRepresentantConsentState(_ state: RequestCaseViewState)
  func documentSelection()
  func attestation()
  func walletPairing()
  func avIdentityCheck()
  func clientAttestationError()
  func keyAttestationError()
  func attestationError(delegate: AttestationErrorDelegate)
}

extension EIDRequestInternalRoutes where Self: RouterProtocol {

  func dataPrivacy() {
    let viewController = UIHostingController(rootView: DataPrivacyView(router: self))
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

  func legalRepresentantConsentState(_ state: RequestCaseViewState) {
    let viewController = UIHostingController(rootView: LegalRepresentantConsentStateView(router: self, state: state))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func documentSelection() {
    let viewController = UIHostingController(rootView: DocumentSelectionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func attestation() {
    let viewController = UIHostingController(rootView: AttestationView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func walletPairing() {
    let viewController = UIHostingController(rootView: WalletPairingView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func avIdentityCheck() {
    let viewController = UIHostingController(rootView: AVIdentityCheckView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func clientAttestationError() {
    let viewController = HideBackButtonHostingController(rootView: ClientAttestationErrorView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func keyAttestationError() {
    let viewController = HideBackButtonHostingController(rootView: KeyAttestationErrorView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func attestationError(delegate: AttestationErrorDelegate) {
    let viewController = HideBackButtonHostingController(rootView: AttestationErrorView(router: self, delegate: delegate))
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
    let style = NavigationPushOpeningStyle()

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
}
