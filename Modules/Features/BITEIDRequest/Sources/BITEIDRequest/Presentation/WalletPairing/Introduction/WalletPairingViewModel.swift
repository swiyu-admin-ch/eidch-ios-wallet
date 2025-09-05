import Factory
import Foundation

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
      try await pairWalletUseCase.execute(for: caseId)

      router.avIdentityCheck()
    } catch EIDRequestRepository.Error.invalidState {
      router.avIdentityCheck()
    } catch {
      #warning("TODO: Redirect to error screen")
    }
  }

  @MainActor
  func secondaryAction() async {
    do {
      guard let caseId = router.context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      try await startOnlineSessionUseCase.execute(for: caseId)

      router.walletPairingList()
    } catch EIDRequestRepository.Error.invalidState {
      router.walletPairingList()
    } catch {
      #warning("TODO: Redirect to error screen")
    }
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

  @Injected(\.pairWalletUseCase) private var pairWalletUseCase
  @Injected(\.startOnlineSessionUseCase) private var startOnlineSessionUseCase

}
