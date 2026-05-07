import BITAnalytics
import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - ScanDocumentViewModel

@MainActor
@Observable
class ScanDocumentViewModel {

  // MARK: Lifecycle

  init() {
    avBeam.messageDelegate = self
    avBeam.scanDocumentDelegate = self
  }

  // MARK: Internal

  enum ScanningState: Equatable {
    case recto
    case verso

    // MARK: Internal

    var title: String {
      switch self {
      case .recto: L10n.tkEidRequestMrzScannerRecto
      case .verso: L10n.tkEidRequestMrzScannerVerso
      }
    }

    var popupTitle: String {
      switch self {
      case .recto: L10n.tkEidRequestMrzScannerNotificationRectoPrimary
      case .verso: L10n.tkEidRequestMrzScannerNotificationVersoPrimary
      }
    }

    var popupContent: String {
      switch self {
      case .recto: L10n.tkEidRequestMrzScannerNotificationRectoSecondary
      case .verso: L10n.tkEidRequestMrzScannerNotificationVersoSecondary
      }
    }
  }

  enum StateView: Equatable {
    case loading
    case camera
  }

  var state = StateView.loading
  var isNotificationPresented = false
  var notification: AVBeamNotification?
  var buttonState = RecordingButton.State.initial
  var destination: EIDRequestDestinations?

  @ObservationIgnored @Injected(\.avBeam) var avBeam: AVBeamProtocol

  var scanFrame = CGRect.zero

  var scanningState = ScanningState.recto

  var overlayImage: (front: Image, back: Image) {
    let image: (ImageAsset, ImageAsset) =
      switch context.identityType {
      case .passport:
        (Assets.Camera.passportFront, Assets.Camera.passportBack)
      default:
        (Assets.Camera.idFront, Assets.Camera.idBack)
      }
    return (image.0.swiftUIImage, image.1.swiftUIImage)
  }

  var title: String {
    scanningState.title
  }

  var buttonStateAccessibilityLabel: String {
    switch buttonState {
    case .initial: L10n.tkEidRequestScanDocumentButtonInitialStateAlt
    case .record: L10n.tkEidRequestScanDocumentButtonRecordStateAlt
    case .loading,
         .success: ""
    }
  }

  func checkInitializationState() {
    switch avBeam.state {
    case .notInitialized:
      avBeam.shutdown()

      do {
        let config = AVBeamInitConfig(appId: avBeamAppID)
        try avBeam.initialize(using: config)
      } catch {
        handleError(error)
      }

    case .initializing:
      state = .loading

    case .initialized:
      startCamera()
    }
  }

  func cancelInitialization(_ navigator: Navigator) {
    avBeam.shutdown()
    navigator.returnToCheckpointSafely(EIDRequestCheckpoints.scanDocumentInformation)
  }

  func stop() {
    avBeam.stopScanDocument()
    try? avBeam.stopCamera()
  }

  func startCamera() {
    let avBeam = avBeam

    Task.detached { [weak self] in
      do {
        try avBeam.startCamera()
        await MainActor.run {
          self?.state = .camera
        }
      } catch {
        await MainActor.run {
          self?.handleError(error)
        }
      }
    }
  }

  func startScan() {
    buttonState = .record

    if scanningState == .verso {
      return avBeam.notifySecondScan()
    }
    do {
      let inputFile = try updateInputFileUseCase()
      let config = AVBeamScanDocumentConfig(files: [inputFile], scanFrame: scanFrame, timeout: 15, isDocumentSideChangeNotificationExpected: true)
      let avBeam = avBeam

      Task.detached { [weak self] in
        do {
          try avBeam.startScanDocument(config: config)
        } catch {
          await MainActor.run {
            self?.handleError(error)
          }
        }
      }
    } catch {
      handleError(error)
    }
  }

  func stopScan() {
    buttonState = .initial
    reset()
    avBeam.stopScanDocument()
  }

  func startScanSecondPage() {
    buttonState = .initial
    scanningState = .verso
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.scanDelay) private var scanDelay
  @ObservationIgnored @Injected(\.avBeamAppID) private var avBeamAppID
  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator
  @ObservationIgnored @Injected(\.compareScanDocumentOutputUseCase) private var compareScanDocumentOutputUseCase: CompareScanDocumentOutputUseCaseProtocol
  @ObservationIgnored @Injected(\.updateEIDRequestCaseFilesUseCase) private var updateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocol
  @ObservationIgnored @Injected(\.updateInputFileUseCase) private var updateInputFileUseCase: UpdateInputFileUseCaseProtocol

  private func reset() {
    scanningState = .recto
    isNotificationPresented = false
    notification = nil
    buttonState = .initial
  }

  private func showSuccessButtonState() async {
    buttonState = .success
    try? await Task.sleep(nanoseconds: scanDelay)
  }

  private func handleScanDocumentOutput(_ output: ScanDocumentOutput) async throws {
    try? await Task.sleep(nanoseconds: scanDelay)

    guard
      let caseId = context.caseId,
      let autoVerificationResponse = context.autoVerificationResponse
    else {
      await showSuccessButtonState()
      destination = .scanDocumentSubmit(output)
      return
    }

    guard await compareScanDocumentOutputUseCase(for: caseId, with: output) else {
      await showSuccessButtonState()
      destination = .error(.ScanDocument.wrongDocument)
      return
    }

    try await updateEIDRequestCaseFilesUseCase(for: caseId, scanDocumentOutput: output)
    await showSuccessButtonState()
    destination =
      autoVerificationResponse.isDocumentVideoRecordingRequired
        ? .recordDocumentInformation : .avIntroSelfieVideo
  }
}

// MARK: AVBeamMessageDelegate

extension ScanDocumentViewModel: AVBeamMessageDelegate {

  nonisolated func didReceiveError(error: AVBeamError) {
    Task { @MainActor in
      analytics.log(error)
    }
  }

  nonisolated func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor [weak self] in
      guard let self else { return }

      switch notification {
      case .initialized:
        do {
          try avBeam.startCamera()
          state = .camera
        } catch {
          handleError(error)
        }

      case .idDocMatched,
           .idDocNotMatched:
        break

      case .streamingStarted:
        buttonState = .initial

      case .idDetectionDone:
        break

      case .idRecognitionStopped:
        break

      case .idNeedSecondPageForMatching:
        destination = .scanDocumentSecondPageInstructions(Callback(handler: { self.startScanSecondPage() }))

      default:
        isNotificationPresented = true
        self.notification = notification
      }
    }
  }
}

// MARK: AVBeamScanDocumentDelegate

extension ScanDocumentViewModel: AVBeamScanDocumentDelegate {
  nonisolated func didCompleteScanDocument(packageResult: AVBeamPackageResult) {
    Task { @MainActor in
      do {
        guard packageResult.data.errorCode == .none else {
          return self.handleError(packageResult.data.errorCode)
        }

        self.buttonState = .loading

        try? avBeam.stopCamera()
        self.isNotificationPresented = false
        self.notification = nil

        let output = try ScanDocumentOutput(
          packageResult, identityType: self.context.identityType ?? .identityCard)
        try await handleScanDocumentOutput(output)
      } catch {
        self.handleError(error)
      }
    }
  }
}

// MARK: - Error Handling

extension ScanDocumentViewModel {

  private func handleError(_ error: Error) {
    analytics.log(error)
    stop()
    destination = .error(errorDataset(for: error))
  }

  private func errorDataset(for error: Error) -> ErrorDataset {
    guard let avBeamError = error as? AVBeamError else {
      return ErrorDataset.retry(error, retryHandler())
    }

    return .avBeamError(avBeamError, retryAction: retryHandler(), closeAction: closeHandler())
  }

  private func closeHandler() -> () -> Void {
    { [weak self] in
      self?.coordinator.cleanup()
    }
  }

  private func retryHandler() -> (Navigator) -> Void {
    { [weak self] navigator in
      self?.reset()
      navigator.returnToCheckpointSafely(EIDRequestCheckpoints.scanDocumentInformation)
    }
  }
}
