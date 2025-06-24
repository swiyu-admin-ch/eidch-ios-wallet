class WalletPairingViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func primaryAction() {
    guard let identityType = router.context.identityType else {
      return router.documentSelection()
    }

    return router.close()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
