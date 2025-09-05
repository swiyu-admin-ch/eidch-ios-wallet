import BITAVWrapper
import BITNavigation
import BITTheming
import SwiftUI


public protocol EIDRequestRoutes {
  func eIDRequest()
  func autoVerification(caseId: String)
  func obtainConsent(caseId: String)
}


protocol EIDRequestInternalRoutes: ClosableRoutes, ExternalRoutes {

  var context: EIDRequestContext { get set }

  func dataPrivacy()
  func cameraPermission()
  func scanDocument()
  func mrzMockData()
  func scanDocumentSubmit(_ scanDocumentOutput: ScanDocumentOutput)
  func queueInformation(_ onlineSessionStartDate: Date)
  func legalRepresentant()
  func legalRepresentantConsent(caseId: String)
  func legalRepresentantQRCode(caseId: String)
  func legalRepresentantConsentState(_ state: RequestCaseViewState)
  func documentSelection()
  func attestation()

  func clientAttestationError()
  func keyAttestationError()
  func validateAttestationsError(delegate: ValidateAttestationsErrorDelegate, error: Error)
  func recordDocument()

  // Wallet Pairing
  func walletPairing()
  func walletPairingList()
  func avIdentityCheck()
  func avIntroSelfieVideo()
  func avDevicePairingQRCode(delegate: DevicePairingDelegate)
  func recordSelfie()
  func nfcScan()
}

// MARK: - eID Request

extension EIDRequestInternalRoutes where Self: RouterProtocol {

  func dataPrivacy() {
    let viewController = UIHostingController(rootView: DataPrivacyView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func cameraPermission() {
    let viewController = UIHostingController(rootView: CameraPermissionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func mrzMockData() {
    let viewController = UIHostingController(rootView: MRZMockDataView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func scanDocument() {
    let viewController = HideBackButtonHostingController(rootView: ScanDocumentView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func scanDocumentSubmit(_ scanDocumentOutput: ScanDocumentOutput) {
    let viewController = HideBackButtonHostingController(rootView: ScanDocumentSubmitView(scanDocumentOutput, router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func queueInformation(_ onlineSessionStartDate: Date) {
    let viewController = HideBackButtonHostingController(rootView: QueueInformationView(router: self, onlineSessionStartDate: onlineSessionStartDate))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func legalRepresentant() {
    let viewController = HideBackButtonHostingController(rootView: LegalRepresentantView(router: self))
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
    let viewController = HideBackButtonHostingController(rootView: ValidateAttestationsView(router: self))
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

  func validateAttestationsError(delegate: ValidateAttestationsErrorDelegate, error: Error) {
    let viewController = HideBackButtonHostingController(rootView: ValidateAttestationsErrorView(router: self, delegate: delegate, error: error))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func recordDocument() {
    let viewController = HideBackButtonHostingController(rootView: RecordDocumentView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }
}

// MARK: - Wallet Pairing

extension EIDRequestInternalRoutes where Self: RouterProtocol {

  func walletPairing() {
    let viewController = HideBackButtonHostingController(rootView: WalletPairingView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func avIdentityCheck() {
    let viewController = HideBackButtonHostingController(rootView: AVIdentityCheckView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func avIntroSelfieVideo() {
    let viewController = HideBackButtonHostingController(rootView: AVIntroSelfieVideoView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func avDevicePairingQRCode(delegate: DevicePairingDelegate) {
    let viewController = UINavigationController(rootViewController: HideBackButtonHostingController(rootView: AVDevicePairingQRCodeView(router: self, delegate: delegate)))
    open(viewController, as: ModalOpeningStyle())
  }

  func recordSelfie() {
    let viewController = HideBackButtonHostingController(rootView: RecordSelfieView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func walletPairingList() {
    let viewController = HideBackButtonHostingController(rootView: WalletPairingListView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func nfcScan() {
    let viewController = HideBackButtonHostingController(rootView: NFCScanView(router: self))
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

  public func autoVerification(caseId: String) {
    let module = AutoVerificationModule(caseId: caseId)
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
