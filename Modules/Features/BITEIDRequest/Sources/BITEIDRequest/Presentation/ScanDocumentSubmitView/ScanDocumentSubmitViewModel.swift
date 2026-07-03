import BITAnalytics
import BITEIDRequestShared
import BITL10n
import BITPushNotification
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - ScanDocumentSubmitViewModel

@MainActor
@Observable
final class ScanDocumentSubmitViewModel {

  // MARK: Lifecycle

  init(scanDocumentOutput: ScanDocumentOutput) {
    self.scanDocumentOutput = scanDocumentOutput
    scanImages = []

    if let firstScanImage = scanDocumentOutput.files.first(where: { $0.fileName == Self.firstScanImageName }) {
      scanImages.append(.image(
        ScanResultEntryImage(
          key: Self.firstScanKey,
          value: firstScanImage.data,
          side: .recto,
          uiOrientation: scanDocumentOutput.scanningOrientiations[.recto],
          accessibilityLabel: L10n.tkEidRequestScanDocumentSubmitFirstScanImageAlt)))
    }

    if let secondScanImage = scanDocumentOutput.files.first(where: { $0.fileName == Self.secondScanImageName }) {
      scanImages.append(.image(
        ScanResultEntryImage(
          key: Self.secondScanKey,
          value: secondScanImage.data,
          side: .verso,
          uiOrientation: scanDocumentOutput.scanningOrientiations[.verso],
          accessibilityLabel: L10n.tkEidRequestScanDocumentSubmitSecondScanImageAlt)))
    }
  }

  // MARK: Internal

  var scanImages: [ScanResultEntryType]
  var isNavigationCloseTriggered = false
  var destination: EIDRequestDestinations?

  func submit() async {
    if context.caseId != nil, context.autoVerificationResponse != nil {
      return await continueAutoVerification()
    }

    await continueEIDRequest()
  }

  func displayScanImageOverview(_ image: ScanResultEntryImage) {
    let fileName: String = switch image.side {
    case .recto: Self.firstFullFrameScanImageName
    case .verso: Self.secondFullFrameScanImageName
    }

    guard let fullFrameScanImage = scanDocumentOutput.files.first(where: { $0.fileName == fileName }) else { return }

    destination = .scanDocumentImageOverview(image: ScanResultEntryImage(
      key: image.key,
      value: fullFrameScanImage.data,
      side: image.side,
      uiOrientation: image.uiOrientation,
      accessibilityLabel: image.accessibilityLabel))
  }

  // MARK: Private

  private static let firstScanImageName = "firstImage.png"
  private static let secondScanImageName = "secondImage.png"
  private static let firstFullFrameScanImageName = "fullFrameFirstPage.png"
  private static let secondFullFrameScanImageName = "fullFrameSecondPage.png"

  private static let firstScanKey = L10n.tkEidRequestScanDocumentSubmitFirstScanImageTitle
  private static let secondScanKey = L10n.tkEidRequestScanDocumentSubmitSecondScanImageTitle

  private let scanDocumentOutput: ScanDocumentOutput
  private let minimumDelayInSeconds: TimeInterval = 2.0

  @ObservationIgnored @Injected(\.eidRequestContext) private var context: EIDRequestContext
  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.applyEIDRequestUseCase) private var applyEIDRequestUseCase: ApplyEIDRequestUseCaseProtocol
  @ObservationIgnored @Injected(\.enablePushNotificationsUseCase) private var enablePushNotificationsUseCase: EnablePushNotificationsUseCaseProtocol
  @ObservationIgnored @Injected(\.compareScanDocumentOutputUseCase) private var compareScanDocumentOutputUseCase: CompareScanDocumentOutputUseCaseProtocol
  @ObservationIgnored @Injected(\.updateEIDRequestCaseFilesUseCase) private var updateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocol
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  private func continueEIDRequest() async {
    do {
      let startTime = Date()
      let requestCase = try await applyEIDRequestUseCase(
        scanDocumentOutput: scanDocumentOutput,
        hasLegalRepresentant: context.hasLegalRepresentant)

      await applyMinimumDelay(startTime: startTime)

      guard
        requestCase.state != nil,
        let destination = try await coordinator.getNextDestination(for: requestCase)
      else {
        return close()
      }

      // Register push token here as permission is already granted so we do not go to the PushPermissionView
      switch destination {
      case .legalRepresentantConsent,
           .queueInformation,
           .walletPairing:
        try await enablePushNotificationsUseCase(for: requestCase.id)
      default: break
      }

      self.destination = destination
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

  private func continueAutoVerification() async {
    guard
      let caseId = context.caseId,
      let autoVerificationResponse = context.autoVerificationResponse
    else {
      return
    }

    guard await compareScanDocumentOutputUseCase(for: caseId, with: scanDocumentOutput) else {
      return destination = .error(.ScanDocument.wrongDocument)
    }

    do {
      try await updateEIDRequestCaseFilesUseCase(for: caseId, scanDocumentOutput: scanDocumentOutput)
      destination = autoVerificationResponse.isDocumentVideoRecordingRequired ? .recordDocumentInformation : .avIntroSelfieVideo
    } catch {
      handleAutoVerificationError(error)
    }
  }

  private func handleAutoVerificationError(_ error: Error) {
    analytics.log(error)
    destination = .error(ErrorDataset.retry(error, retryAutoVerification))
  }

  private func retryAutoVerification(_ navigator: Navigator) {
    navigator.returnToCheckpoint(EIDRequestCheckpoints.scanDocumentInformation)
  }

  private func openHelp() {
    guard let url = URL(string: L10n.tkEidRequestSubmitErrorTertiaryLink) else { return }
    UIApplication.shared.open(url)
  }

  // MARK: - Delay Management

  private func applyMinimumDelay(startTime: Date) async {
    let elapsedTime = calculateElapsedTime(startTime: startTime)
    let remainingDelay = calculateRemainingDelay(elapsedTime: elapsedTime)

    if remainingDelay > 0 {
      try? await Task.sleep(seconds: remainingDelay)
    }
  }

  private func calculateElapsedTime(startTime: Date) -> TimeInterval {
    Date().timeIntervalSince(startTime)
  }

  private func calculateRemainingDelay(elapsedTime: TimeInterval) -> TimeInterval {
    max(0, minimumDelayInSeconds - elapsedTime)
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
