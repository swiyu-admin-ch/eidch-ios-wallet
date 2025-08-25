import Factory

class WalletPairingViewModel {

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

      try await startOnlineSessionUseCase.execute(for: caseId)
      router.avIdentityCheck()
    } catch {
    }
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

  @Injected(\.startOnlineSessionUseCase) private var startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocol
}
