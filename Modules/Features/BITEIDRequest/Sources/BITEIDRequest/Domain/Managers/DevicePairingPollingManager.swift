import Factory
import Foundation
import Spyable
import SwiftUI

// MARK: - WalletPairingPollingProtocol

@MainActor @Spyable
protocol WalletPairingPollingProtocol: AnyObject {
  var delegate: WalletPairingPollingDelegate? { get set }
  var isPolling: Bool { get }
  var state: WalletPairingPollingManager.State { get }

  func startPolling(for caseId: String, pairingId: String)
  func stopPolling()
  func reset()
}

// MARK: - WalletPairingPollingDelegate

@MainActor @Spyable
protocol WalletPairingPollingDelegate: AnyObject {
  func pollingManager(_ manager: any WalletPairingPollingProtocol, didUpdateState state: WalletPairingPollingManager.State)
}

// MARK: - WalletPairingPollingManager

@MainActor
class WalletPairingPollingManager: WalletPairingPollingProtocol {

  // MARK: Lifecycle

  init(pollingInterval: TimeInterval = 5.0) {
    self.pollingInterval = pollingInterval
  }

  // MARK: Internal

  enum State: Equatable {
    case state(WalletPairingState)
    case error(String)
  }

  weak var delegate: WalletPairingPollingDelegate?
  private(set) var isPolling = false
  private(set) var state = State.state(.open)

  func startPolling(for caseId: String, pairingId: String) {
    guard !isPolling else { return }

    isPolling = true
    updateState(.state(.open))

    pollingTask = Task { [weak self] in
      await self?.pollDevicePairingStatus(for: caseId, pairingId: pairingId)
    }
  }

  func stopPolling() {
    guard isPolling else { return }

    pollingTask?.cancel()
    pollingTask = nil
    isPolling = false
  }

  func reset() {
    stopPolling()
    updateState(.state(.open))
  }

  // MARK: Private

  private var pollingTask: Task<Void, Never>?
  private let pollingInterval: TimeInterval

  @Injected(\.fetchWalletPairingStateUseCase) private var fetchWalletPairingStateUseCase

  private func updateState(_ newState: State) {
    state = newState
    delegate?.pollingManager(self, didUpdateState: newState)
  }

  private func pollDevicePairingStatus(for caseId: String, pairingId: String) async {
    while !Task.isCancelled && isPolling {
      do {
        let pairingState = try await fetchWalletPairingStateUseCase.execute(for: caseId, pairingId: pairingId)
        updateState(.state(pairingState))

        guard !Task.isCancelled else { break }

        switch pairingState {
        case .accepted,
             .rejected:
          stopPolling()
        case .open:
          break
        }
      } catch {
        guard !Task.isCancelled else { break }
        let errorState = State.error(error.localizedDescription)
        updateState(errorState)
        stopPolling()
        return
      }

      try? await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
    }
  }
}
