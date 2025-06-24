class AVIdentityCheckViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func primaryAction() {
    router.walletPairing()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
