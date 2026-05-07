import BITEIDRequestShared
import BITL10n
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - ScanDocumentSubmitViewModel

@MainActor
@Observable
class ScanDocumentSubmitViewModel {

  // MARK: Lifecycle

  init(scanDocumentOutput: ScanDocumentOutput) {
    self.scanDocumentOutput = scanDocumentOutput
    scanImages = []

    if let firstScanImage = scanDocumentOutput.files.first(where: { $0.fileName == Self.firstScanImageName }), let identityType = context.identityType {
      scanImages.append(.image(key: Self.firstScanKey, value: firstScanImage.data, accessibilityLabel: L10n.tkEidRequestScanDocumentSubmitFirstScanImageAlt(identityType.document)))
    }

    if let secondScanImage = scanDocumentOutput.files.first(where: { $0.fileName == Self.secondScanImageName }), let identityType = context.identityType {
      scanImages.append(.image(key: Self.secondScanKey, value: secondScanImage.data, accessibilityLabel: L10n.tkEidRequestScanDocumentSubmitSecondScanImageAlt(identityType.document)))
    }
  }

  // MARK: Internal

  var scanImages: [ScanResultEntryType]
  var isNavigationCloseTriggered = false
  var destination: EIDRequestDestinations?

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

  private static let firstScanImageName = "firstImage.png"
  private static let secondScanImageName = "secondImage.png"

  private static let firstScanKey = L10n.tkEidRequestScanDocumentSubmitFirstScanImageTitle
  private static let secondScanKey = L10n.tkEidRequestScanDocumentSubmitSecondScanImageTitle

  private let scanDocumentOutput: ScanDocumentOutput
  private let minimumDelayInSeconds: TimeInterval = 2.0

  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.applyEIDRequestUseCase) private var applyEIDRequestUseCase
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator

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

extension IdentityType {
  var document: String {
    switch self {
    case .passport: L10n.tkEidRequestDocumentSelectionPassport
    case .foreignerPermit: L10n.tkEidRequestDocumentSelectionResidentPermit
    case .identityCard: L10n.tkEidRequestDocumentSelectionIdCard
    }
  }
}
