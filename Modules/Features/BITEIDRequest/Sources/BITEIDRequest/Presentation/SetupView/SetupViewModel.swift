import BITAppAuth
import BITAVWrapper
import BITL10n
import BITLocalAuthentication
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - SetupViewModel

class SetupViewModel: ObservableObject {

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?
  @Published var isNavigationCloseTriggered = false

  @MainActor
  func fetchAttestations() async {
    guard let context = userSession.context else {
      return destination = .setupSDKError(error: ErrorWrapper(UserSessionError.notLoggedIn), Callback<Void> { self.handleCallback() })
    }

    let startTime = Date()

    do {
      try await fetchAttestationsUseCase.execute(context)

      Task.detached { [weak self] in
        guard let self else {
          return
        }

        try? avBeam.initialize(using: AVBeamInitConfig(appId: avBeamAppID))
      }

      await applyMinimumDelay(startTime: startTime)

      return destination = .legalRepresentant
    } catch {
      return await handleError(error, startTime: startTime)
    }
  }

  func cancelInitialization() {
    avBeam.shutdown()
    isNavigationCloseTriggered = true
  }

  // MARK: Private

  private let minimumDelayInSeconds: TimeInterval = 2.0

  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.avBeam) private var avBeam: AVBeamProtocol
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
      return destination = .error(.clientAttestation)
    case EIDRequestRepository.Error.invalidKeyAttestation:
      return destination = .error(.keyAttestation)
    default:
      return destination = .error(.retry(error) { _ in self.handleCallback() })
    }
  }

  private func handleCallback() {
    Task {
      await fetchAttestations()
    }
  }
}

extension ErrorDataset {

  // MARK: Internal

  @MainActor
  static var keyAttestation: Self {
    ErrorDataset([
      .title(L10n.tkEidRequestKeyAttestationErrorPrimary),
      .body(L10n.tkEidRequestKeyAttestationErrorSecondary),
      .caption(L10n.tkEidRequestKeyAttestationErrorTertiary),
    ], actions: [
      .primary(L10n.tkEidRequestKeyAttestationErrorPrimaryButton) { navigator in
        navigator.dismiss()
      },
    ])
  }

  @MainActor
  static var clientAttestation: Self {
    ErrorDataset([
      .title(L10n.tkEidRequestClientAttestationErrorPrimary),
      .body(L10n.tkEidRequestClientAttestationErrorSecondary),
      .captionButton(L10n.tkEidRequestClientAttestationErrorTertiary) { _ in
        self.openLink(L10n.tkEidRequestClientAttestationErrorHelpLink)
      },
    ], actions: [
      .primary(L10n.tkEidRequestClientAttestationErrorPrimaryButton) { _ in
        self.openLink(L10n.tkGlobalStoreLink)
      },
      .secondary(L10n.tkEidRequestClientAttestationErrorSecondaryButton) { navigator in
        navigator.dismiss()
      },
    ])
  }

  // MARK: Private

  private static func openLink(_ link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.open(url)
  }
}
