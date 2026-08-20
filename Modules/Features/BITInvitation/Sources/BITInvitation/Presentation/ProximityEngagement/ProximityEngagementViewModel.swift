import BITCore
import BITL10n
import BITOpenID
import BITPresentation
import BITQRCode
import Factory
import Foundation
import NavigatorUI

// MARK: - ProximityEngagementViewModel

@MainActor
@Observable
final class ProximityEngagementViewModel: Vibrating {

  // MARK: Lifecycle

  deinit {
    proximityTask?.cancel()
  }

  // MARK: Internal

  var qrCodePayload: String?

  var error: Error?
  var isErrorPopupPresented = false
  var destination: InvitationDestinations?

  func start() {
    guard proximityTask == nil else { return }
    qrCodePayload = nil
    startObservingState()
  }

  func closeErrorView() {
    error = nil
    isErrorPopupPresented = false
    destination = nil
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.startProximityEngagementUseCase) private var startProximityEngagementUseCase: StartProximityEngagementUseCaseProtocol
  @ObservationIgnored @Injected(\.invitationErrorMapper) private var invitationErrorMapper: InvitationErrorMapping

  @ObservationIgnored nonisolated(unsafe) private var proximityTask: Task<Void, Never>?

  private func reset() {
    proximityTask?.cancel()
    proximityTask = nil
    qrCodePayload = nil
  }

  private func startObservingState() {
    proximityTask?.cancel()

    proximityTask = Task { @MainActor [weak self] in
      guard let stream = self?.startProximityEngagementUseCase() else { return }

      do {
        for try await event in stream {
          try self?.handleProximityEvent(event)
        }
      } catch is CancellationError {
        // ignore
      } catch {
        self?.handleError(error)
      }
    }
  }

  private func handleError(_ error: Error) {
    vibrate(.error)

    let mappedError = invitationErrorMapper(error)
    self.error = mappedError
    isErrorPopupPresented = true
  }

  private func handleProximityEvent(_ event: ProximityEngagementEvent) throws {
    switch event {
    case .qrCode(let qrCode):
      qrCodePayload = qrCode
    case .request(let context):
      destination = .external(.presentation(context))
    }
  }
}
