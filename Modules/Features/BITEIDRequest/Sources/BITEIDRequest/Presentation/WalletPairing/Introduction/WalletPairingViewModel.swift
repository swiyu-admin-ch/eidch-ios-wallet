import BITTheming
import Factory
import Foundation

@MainActor
@Observable
final class WalletPairingViewModel {

  // MARK: Internal

  var destination: EIDRequestDestinations?

  func primaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      try await startOnlineSession(for: caseId)

      let pairingId = try await pairWalletUseCase.execute(for: caseId)
      try await saveWalletPairingIdUseCase(pairingId, forRequestCase: caseId)

      destination = .avIdentityCheck(caseId: caseId)
    } catch {
      handle(error: error)
    }
  }

  func secondaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      try await startOnlineSession(for: caseId)
      destination = .walletPairingList(caseId: caseId)
    } catch {
      handle(error: error)
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.pairWalletUseCase) private var pairWalletUseCase: PairWalletUseCaseProtocol
  @ObservationIgnored @Injected(\.startOnlineSessionUseCase) private var startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocol
  @ObservationIgnored @Injected(\.saveWalletPairingIdUseCase) private var saveWalletPairingIdUseCase: SaveWalletPairingIdUseCaseProtocol
  @ObservationIgnored @Injected(\.resetRequestCasePairingUseCase) private var resetRequestCasePairingUseCase: ResetRequestCasePairingUseCaseProtocol

  private func handle(error: Error) {
    destination = .error(.retry(error) { navigator in
      navigator.pop()
    })
  }

  private func startOnlineSession(for caseId: String) async throws {
    try await resetRequestCasePairingUseCase(for: caseId)
    try await startOnlineSessionUseCase.execute(for: caseId)
  }

}
