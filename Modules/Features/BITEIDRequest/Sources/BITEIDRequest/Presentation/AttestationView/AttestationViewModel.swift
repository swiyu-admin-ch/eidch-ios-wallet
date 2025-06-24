import BITAppAttestation
import BITAppAuth
import BITLocalAuthentication
import Factory
import Foundation
import SwiftUI

// MARK: - AttestationViewModel

class AttestationViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @MainActor
  func fetchAttestations() async {
    guard let context = userSession.context else {
      return router.attestationError(delegate: self)
    }

    let startTime = Date()

    do {
      let clientAttestation = try await fetchClientAttestationUseCase.execute(context)
      let keyAttestation = try await fetchKeyAttestationUseCase.execute(context)
      try await validateAttestationsUseCase.execute(clientAttestation: clientAttestation, keyAttestation: keyAttestation)

      await applyMinimumDelay(startTime: startTime)

      return router.legalRepresentant()
    } catch {
      return await handleError(error, startTime: startTime)
    }
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
  private let minimumDelayInSeconds: TimeInterval = 3.0

  @Injected(\.userSession) private var userSession: Session
  @Injected(\.fetchClientAttestationUseCase) private var fetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocol
  @Injected(\.fetchKeyAttestationUseCase) private var fetchKeyAttestationUseCase: FetchKeyAttestationUseCaseProtocol
  @Injected(\.validateAttestationsUseCase) private var validateAttestationsUseCase: ValidateAttestationsUseCaseProtocol

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
      return router.attestationError(delegate: self)
    }
  }
}

// MARK: AttestationErrorDelegate

extension AttestationViewModel: AttestationErrorDelegate {
  func didTapPrimaryAction() {
    Task {
      await fetchAttestations()
    }
  }
}
