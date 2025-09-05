import Factory

class AVIdentityCheckViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @MainActor
  func primaryAction() async {
    do {
      guard let caseId = router.context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      let response = try await startAutoVerificationUseCase.execute(for: caseId)

      guard response.isNFCRequired else {
        return router.recordDocument()
      }

      return router.nfcScan()
    } catch {
      #warning("TODO: Handle error case here when implemented")
    }
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

  @Injected(\.startAutoVerificationUseCase) private var startAutoVerificationUseCase
}
