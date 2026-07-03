import BITEIDRequestShared
import Factory
import Observation

@Observable @MainActor
final class PushPermissionViewModel {

  // MARK: Lifecycle

  init(_ requestCase: EIDRequestCase) {
    self.requestCase = requestCase
  }

  // MARK: Internal

  var isNavigationCloseTriggered = false
  var destination: EIDRequestDestinations?

  func continueNavigation(withPush: Bool) async {
    do {
      if withPush {
        try await enablePushNotificationsUseCase(for: requestCase.id)
      }

      continueNavigation()
    } catch {
      presentError()
    }
  }

  func presentError() {
    destination = .error(Self.errorDataset(retryAction: { navigator in
      navigator.pop()
    }, skipAction: { navigator in
      navigator.pop()
      self.continueNavigation()
    }))
  }

  // MARK: Private

  private let requestCase: EIDRequestCase

  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator
  @ObservationIgnored @Injected(\.enablePushNotificationsUseCase) private var enablePushNotificationsUseCase: EnablePushNotificationsUseCaseProtocol

  private func continueNavigation() {
    guard let destination = try? coordinator.getNextDestinationAfterApply(for: requestCase) else {
      return isNavigationCloseTriggered = true
    }

    self.destination = destination
  }
}
