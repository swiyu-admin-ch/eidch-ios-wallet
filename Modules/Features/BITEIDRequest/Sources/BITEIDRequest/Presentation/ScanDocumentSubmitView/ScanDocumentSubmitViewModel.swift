import BITAVWrapper
import BITNetworking
import Factory
import Foundation

@MainActor
class ScanDocumentSubmitViewModel: ObservableObject {

  // MARK: Lifecycle

  init(scanDocumentOutput: ScanDocumentOutput, router: EIDRequestInternalRoutes) {
    self.scanDocumentOutput = scanDocumentOutput
    self.router = router
  }

  // MARK: Internal

  func submit() async {
    do {
      let startTime = Date()
      let requestCase = try await submitEIDRequestUseCase.execute(
        scanDocumentOutput: scanDocumentOutput,
        hasLegalRepresentant: router.context.hasLegalRepresentant)

      await applyMinimumDelay(startTime: startTime)

      guard requestCase.state != nil else {
        return close()
      }

      let viewState = try RequestCaseViewState(requestCase)
      router.context.caseId = requestCase.id

      if !viewState.isLegalRepresentantConsentVerified {
        return router.legalRepresentantConsent(caseId: requestCase.id)
      }

      return switch viewState {
      case .inQueue(let state): router.queueInformation(state.onlineSessionStartOpenAt)
      case .readyForOnlineSession: router.walletPairing()
      default: close()
      }
    } catch {
    }
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private var router: EIDRequestInternalRoutes
  private let scanDocumentOutput: ScanDocumentOutput
  private let minimumDelayInSeconds: TimeInterval = 2.0

  @Injected(\.submitEIDRequestUseCase) private var submitEIDRequestUseCase

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

}
