import BITNavigation
import Factory
import Foundation

@MainActor
class WalletPairingViewModel: NavigationClosable {

  // MARK: Internal

  @Published var isNavigationCloseTriggered = false
  @Published var destination: EIDRequestDestinations?

  @MainActor
  func primaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      try await startOnlineSessionUseCase.execute(for: caseId)
      try await pairWalletUseCase.execute(for: caseId)

      destination = .avIdentityCheck
    } catch EIDRequestRepository.Error.invalidState {
      return destination = .avIdentityCheck
    } catch {
      #warning("TODO: Redirect to error screen")
    }
  }

  @MainActor
  func secondaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      try await startOnlineSessionUseCase.execute(for: caseId)

      destination = .walletPairingList
    } catch EIDRequestRepository.Error.invalidState {
      destination = .walletPairingList
    } catch {
      #warning("TODO: Redirect to error screen")
    }
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
  @Injected(\.pairWalletUseCase) private var pairWalletUseCase
  @Injected(\.startOnlineSessionUseCase) private var startOnlineSessionUseCase

}
