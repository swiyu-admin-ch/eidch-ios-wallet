import BITCore
import BITEIDRequestShared
import Factory
import Foundation
import Spyable

// MARK: - RequestCasePollingProtocol

@MainActor @Spyable
public protocol RequestCasePollingProtocol: AnyObject {
  var delegate: RequestCasePollingDelegate? { get set }

  func stopPolling()
  func startPolling(for caseId: String)
}

// MARK: - RequestCasePollingDelegate

@MainActor @Spyable
public protocol RequestCasePollingDelegate: AnyObject {
  func didCompletePolling(with state: EIDRequestStatus.State)
}

// MARK: - RequestCasePollingManager

@MainActor
final class RequestCasePollingManager: RequestCasePollingProtocol {

  // MARK: Lifecycle

  init(pollingInterval: TimeInterval = 5.0, timeout: TimeInterval = 60.0) {
    self.pollingInterval = pollingInterval
    self.timeout = timeout
  }

  // MARK: Internal

  weak var delegate: RequestCasePollingDelegate?

  func startPolling(for caseId: String) {
    guard !isPolling else {
      return
    }

    isPolling = true

    pollingTask = Task { [weak self] in
      await self?.fetchRequestCaseStatus(for: caseId)
    }

    startTimeoutTimer()
  }

  func stopPolling() {
    guard isPolling else {
      return
    }

    invalidateTimeoutTimer()
    pollingTask?.cancel()
    pollingTask = nil
    isPolling = false
  }

  // MARK: Private

  private var isPolling = false

  private let timeout: TimeInterval
  private let pollingInterval: TimeInterval
  private var pollingTask: Task<Void, Never>?
  private var timeoutTimer: Timer?

  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase

  private func startTimeoutTimer() {
    invalidateTimeoutTimer()

    timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
      Task { @MainActor in
        self?.stopPolling()
      }
    }
  }

  private func invalidateTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  private func fetchRequestCaseStatus(for caseId: String) async {
    while !Task.isCancelled, isPolling {
      do {
        let requestCase = try await updateEIDRequestCaseStatusUseCase.execute(for: caseId)

        guard !Task.isCancelled else {
          break
        }

        guard let state = requestCase.state?.state else {
          return stopPolling()
        }

        switch state {
        case .autoVerification: break
        default:
          stopPolling()
          delegate?.didCompletePolling(with: state)
          return
        }
      } catch {
        guard !Task.isCancelled else {
          break
        }

        return stopPolling()
      }

      try? await Task.sleep(seconds: pollingInterval)
    }
  }
}
