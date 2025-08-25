import BITAppAuth
import BITLocalAuthentication
import Factory
import Foundation
import SwiftUI

// MARK: - ValidateAttestationsViewModelProtocol

protocol ValidateAttestationsViewModelProtocol {
  func fetchAttestations() async
}

// MARK: - ValidateAttestationsViewModel

class ValidateAttestationsViewModel: ValidateAttestationsViewModelProtocol {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @MainActor
  func fetchAttestations() async {
    guard let context = userSession.context else {
      return router.validateAttestationsError(delegate: self, error: UserSessionError.notLoggedIn)
    }

    let startTime = Date()

    do {
      try await fetchAttestationsUseCase.execute(context)

      await applyMinimumDelay(startTime: startTime)

      return router.legalRepresentant()
    } catch {
      return await handleError(error, startTime: startTime)
    }
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
  private let minimumDelayInSeconds: TimeInterval = 2.0

  @Injected(\.userSession) private var userSession: Session
  @Injected(\.fetchAttestationsUseCase) private var fetchAttestationsUseCase

  // MARK: - Delay Management

  private func applyMinimumDelay(startTime: Date) async {
    let elapsedTime = calculateElapsedTime(startTime: startTime)
    let remainingDelay = calculateRemainingDelay(elapsedTime: elapsedTime)

    if remainingDelay > 0 {
      await sleepForDuration(remainingDelay)
    }
  }

  private func calculateElapsedTime(startTime: Date) -> TimeInterval {
    Date().timeIntervalSince(startTime)
  }

  private func calculateRemainingDelay(elapsedTime: TimeInterval) -> TimeInterval {
    max(0, minimumDelayInSeconds - elapsedTime)
  }

  private func sleepForDuration(_ duration: TimeInterval) async {
    let nanoseconds = UInt64(duration * 1_000_000_000)
    try? await Task.sleep(nanoseconds: nanoseconds)
  }

  @MainActor
  private func handleError(_ error: Error, startTime: Date) async {
    await applyMinimumDelay(startTime: startTime)

    switch error {
    case EIDRequestRepository.Error.invalidClientAttestation:
      return router.clientAttestationError()
    case EIDRequestRepository.Error.invalidKeyAttestation:
      return router.keyAttestationError()
    default:
      return router.validateAttestationsError(delegate: self, error: error)
    }
  }
}

// MARK: ValidateAttestationsErrorDelegate

extension ValidateAttestationsViewModel: ValidateAttestationsErrorDelegate {
  func didTapPrimaryAction() {
    Task {
      await fetchAttestations()
    }
  }
}
