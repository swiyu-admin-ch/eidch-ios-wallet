import BITL10n
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

@MainActor
class ScanDocumentSubmitViewModel: ObservableObject {

  // MARK: Lifecycle

  init(scanDocumentOutput: ScanDocumentOutput) {
    self.scanDocumentOutput = scanDocumentOutput
  }

  // MARK: Internal

  @Published var isNavigationCloseTriggered = false
  @Published var destination: EIDRequestDestinations?

  func submit() async {
    do {
      let startTime = Date()
      let requestCase = try await applyEIDRequestUseCase(
        scanDocumentOutput: scanDocumentOutput,
        hasLegalRepresentant: context.hasLegalRepresentant)

      await applyMinimumDelay(startTime: startTime)

      guard requestCase.state != nil else {
        return close()
      }

      let viewState = try RequestCaseViewState(requestCase)
      context.caseId = requestCase.id

      if !viewState.isLegalRepresentantConsentVerified {
        return destination = .legalRepresentantConsent(caseId: requestCase.id)
      }

      switch viewState {
      case .inQueue(let state):
        destination = .queueInformation(state.onlineSessionStartOpenAt)
      case .readyForOnlineSession:
        destination = .walletPairing
      default: close()
      }
    } catch {
      destination = .error(ErrorDataset(
        primary: L10n.tkEidRequestSubmitErrorPrimary,
        secondary: L10n.tkEidRequestSubmitErrorSecondary,
        tertiary: L10n.tkEidRequestSubmitErrorTertiary,
        primaryAction: {
          Task {
            await self.submit()
          }
        },
        primaryActionLabel: L10n.tkEidRequestSubmitErrorPrimaryButton,
        tertiaryAction: openHelp))
    }
  }

  // MARK: Private

  private let scanDocumentOutput: ScanDocumentOutput
  private let minimumDelayInSeconds: TimeInterval = 2.0

  @Injected(\.eidRequestContext) private var context
  @Injected(\.applyEIDRequestUseCase) private var applyEIDRequestUseCase
  @Injected(\.eidRequestFlowCoordinator) private var coordinator

  private func openHelp() {
    guard let url = URL(string: L10n.tkEidRequestSubmitErrorTertiaryLink) else { return }
    UIApplication.shared.open(url)
  }

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

  private func close() {
    isNavigationCloseTriggered = true
    coordinator.cleanup()
  }

}
