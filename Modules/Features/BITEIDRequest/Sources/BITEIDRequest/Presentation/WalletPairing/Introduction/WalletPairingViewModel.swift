import BITTheming
import Factory
import Foundation

@MainActor
@Observable
class WalletPairingViewModel {

  // MARK: Internal

  var destination: EIDRequestDestinations?

  @MainActor
  func primaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      try await startOnlineSessionUseCase.execute(for: caseId)
      try await pairWalletUseCase.execute(for: caseId)

      destination = .avIdentityCheck(caseId: caseId)
    } catch {
      destination = .error(.retry(error) { [weak self] _ in
        Task {
          await self?.primaryAction()
        }
      })
    }
  }

  @MainActor
  func secondaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }
      try await startOnlineSessionUseCase.execute(for: caseId)

      destination = .walletPairingList(caseId: caseId)
    } catch {
      #warning("TODO: Redirect to error screen")
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.pairWalletUseCase) private var pairWalletUseCase
  @ObservationIgnored @Injected(\.startOnlineSessionUseCase) private var startOnlineSessionUseCase
}
