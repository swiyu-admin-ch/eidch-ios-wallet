class AVWelcomeViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func primaryAction() {
    router.walletPairing()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
