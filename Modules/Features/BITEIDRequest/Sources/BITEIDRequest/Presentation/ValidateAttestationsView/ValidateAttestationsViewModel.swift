import BITAppAuth
import BITL10n
import BITLocalAuthentication
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - ValidateAttestationsViewModel

class ValidateAttestationsViewModel: ObservableObject, NavigationClosable {

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?
  @Published var isNavigationCloseTriggered = false

  @MainActor
  func fetchAttestations() async {
    guard let context = userSession.context else {
      return destination = .validateAttestationError(error: ErrorWrapper(UserSessionError.notLoggedIn), Callback<Void> { self.handleCallback() })
    }

    let startTime = Date()

    do {
      try await fetchAttestationsUseCase.execute(context)

      await applyMinimumDelay(startTime: startTime)

      return destination = .legalRepresentant
    } catch {
      return await handleError(error, startTime: startTime)
    }
  }

  // MARK: Private

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
      return destination = .error(ErrorDataset(
        primary: L10n.tkEidRequestClientAttestationErrorPrimary,
        secondary: L10n.tkEidRequestClientAttestationErrorSecondary,
        tertiary: L10n.tkEidRequestClientAttestationErrorTertiary,
        primaryAction: { self.openLink(L10n.tkGlobalStoreLink) },
        primaryActionLabel: L10n.tkEidRequestClientAttestationErrorPrimaryButton,
        secondaryAction: {
          self.isNavigationCloseTriggered = true
        },
        secondaryActionLabel: L10n.tkEidRequestClientAttestationErrorSecondaryButton,
        tertiaryAction: { self.openLink(L10n.tkEidRequestClientAttestationErrorHelpLink) }))
    case EIDRequestRepository.Error.invalidKeyAttestation:
      return destination = .error(ErrorDataset(
        primary: L10n.tkEidRequestKeyAttestationErrorPrimary,
        secondary: L10n.tkEidRequestKeyAttestationErrorSecondary,
        tertiary: L10n.tkEidRequestKeyAttestationErrorTertiary,
        primaryActionLabel: L10n.tkEidRequestKeyAttestationErrorPrimaryButton))
    default:
      return destination = .error(ErrorDataset(error, primaryAction: { self.handleCallback() }))
    }
  }

  private func handleCallback() {
    Task {
      await fetchAttestations()
    }
  }

  private func openLink(_ link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.open(url)
  }
}
