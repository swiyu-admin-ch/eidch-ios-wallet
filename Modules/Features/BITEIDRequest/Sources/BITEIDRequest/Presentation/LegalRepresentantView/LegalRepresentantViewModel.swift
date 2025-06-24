@MainActor
class LegalRepresentantViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func action(_ value: Bool) {
    router.context.hasLegalRepresentant = value
    router.documentSelection()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
