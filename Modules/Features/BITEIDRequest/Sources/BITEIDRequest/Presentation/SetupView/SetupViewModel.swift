import BITAppAuth
import BITAVWrapper
import BITLocalAuthentication
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - SetupViewModel

@Observable

class SetupViewModel {

  // MARK: Internal

  var destination: EIDRequestDestinations?

  @MainActor
  func fetchAttestations() async {
    guard let context = userSession.context else {
      return destination = .setupSDKError(error: ErrorWrapper(UserSessionError.notLoggedIn), Callback<Void> { self.handleCallback() })
    }

    let startTime = Date()

    do {
      Task.detached { [weak self] in
        guard let self else {
          return
        }

        try? avBeam.initialize(using: AVBeamInitConfig(appId: avBeamAppID))
      }

      try await validateDeviceSecurityRequirementsUseCase(context)

      await applyMinimumDelay(startTime: startTime)

      return destination = .legalRepresentant
    } catch {
      return await handleError(error, startTime: startTime)
    }
  }

  @MainActor
  func cancelInitialization(_ navigator: Navigator) {
    avBeam.shutdown()
    navigator.dismiss()
  }

  // MARK: Private

  private let minimumDelayInSeconds: TimeInterval = 2.0

  @ObservationIgnored @Injected(\.avBeamAppID) private var avBeamAppID
  @ObservationIgnored @Injected(\.avBeam) private var avBeam: AVBeamProtocol
  @ObservationIgnored @Injected(\.userSession) private var userSession: Session
  @ObservationIgnored @Injected(\.validateDeviceSecurityRequirementsUseCase) private var validateDeviceSecurityRequirementsUseCase

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
    case SIDRepository.Error.invalidClientAttestation:
      return destination = .error(.Setup.clientAttestation)
    case SIDRepository.Error.invalidKeyAttestation:
      return destination = .error(.Setup.keyAttestation)
    case ValidateDeviceSecurityRequirementsUseCaseError.attestationServiceDeactivated,
         ValidateDeviceSecurityRequirementsUseCaseError.attestationTimeout:
      return destination = .error(.Setup.attestationServiceError)
    default:
      return destination = .error(.retry(error) { [weak self] navigator in
        guard let self else { return }
        navigator.pop()
        handleCallback()
      })
    }
  }

  private func handleCallback() {
    Task {
      await fetchAttestations()
    }
  }
}
