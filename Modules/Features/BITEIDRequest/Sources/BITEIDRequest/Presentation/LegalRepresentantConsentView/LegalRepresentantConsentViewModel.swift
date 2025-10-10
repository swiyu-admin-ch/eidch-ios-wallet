import Factory

@MainActor
class LegalRepresentantConsentViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, caseId: String) {
    self.router = router
    self.caseId = caseId
  }

  // MARK: Internal

  func obtainConsent() {
    router.legalRepresentantQRCode(caseId: caseId)
  }

  func continueAsParent() {
    router.legalRepresentantVerification(caseId: caseId)
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let caseId: String
  private let router: EIDRequestInternalRoutes
}
