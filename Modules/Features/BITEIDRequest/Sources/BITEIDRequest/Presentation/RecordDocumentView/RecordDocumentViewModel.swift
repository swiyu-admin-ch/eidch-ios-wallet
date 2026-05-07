import BITAnalytics
import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - RecordDocumentViewModel

@MainActor
@Observable
final class RecordDocumentViewModel {

  // MARK: Lifecycle

  init() {
    avBeam.messageDelegate = self
    avBeam.recordDocumentDelegate = self
  }

  // MARK: Internal

  enum ScanningState: Equatable {
    case recto
    case verso

    // MARK: Internal

    var title: String {
      switch self {
      case .recto: L10n.tkEidRequestRecordDocumentRecto
      case .verso: L10n.tkEidRequestRecordDocumentVerso
      }
    }

    var popupTitle: String {
      switch self {
      case .recto: L10n.tkEidRequestRecordDocumentNotificationRectoPrimary
      case .verso: L10n.tkEidRequestRecordDocumentNotificationVersoPrimary
      }
    }

    var popupContent: String {
      switch self {
      case .recto: L10n.tkEidRequestRecordDocumentNotificationRectoSecondary
      case .verso: L10n.tkEidRequestRecordDocumentNotificationVersoSecondary
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
  var timer: Timer?
  var buttonState = RecordingButton.State.initial

  var destination: EIDRequestDestinations?

  @ObservationIgnored @Injected(\.avBeam) var avBeam: AVBeamProtocol

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

  var buttonStateAccessibilityLabel: String {
    switch buttonState {
    case .initial: L10n.tkEidRequestRecordDocumentButtonInitialStateAlt
    case .record: L10n.tkEidRequestRecordDocumentButtonRecordStateAlt
    case .loading,
         .success: ""
    }
  }

  var title: String {
    scanningState.title
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

  func stop() {
    avBeam.stopRecordDocument()
    try? avBeam.stopCamera()
  }

  func cancelInitialization(_ navigator: Navigator) {
    avBeam.shutdown()
    navigator.returnToCheckpointSafely(EIDRequestCheckpoints.recordDocumentInformation)
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

  func startRecordDocument() {
    do {
      let inputFile = try updateInputFileUseCase()
      let config = AVBeamRecordDocumentConfig(files: [inputFile], timeout: recordDocumentTimeout)
      let avBeam = avBeam

      buttonState = .record

      Task.detached { [weak self] in
        do {
          try avBeam.startRecordDocument(config: config)
          await MainActor.run {
            self?.state = .camera
          }
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

  func stopRecordDocument() {
    reset()
    avBeam.stopRecordDocument()
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.scanDelay) private var scanDelay
  @ObservationIgnored @Injected(\.saveEIDRequestFilesUseCase) private var saveEIDRequestFilesUseCase
  @ObservationIgnored @Injected(\.recordDocumentTimeout) private var recordDocumentTimeout
  @ObservationIgnored @Injected(\.avBeamAppID) private var avBeamAppID
  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator
  @ObservationIgnored @Injected(\.updateInputFileUseCase) private var updateInputFileUseCase: UpdateInputFileUseCaseProtocol

  private func reset() {
    scanningState = .recto
    isNotificationPresented = false
    notification = nil
    buttonState = .initial
    timer?.invalidate()
    timer = nil
  }
}

// MARK: AVBeamMessageDelegate

extension RecordDocumentViewModel: AVBeamMessageDelegate {
  nonisolated func didReceiveError(error: AVBeamError) {
    Task { @MainActor in
      analytics.log(error)
    }
  }

  nonisolated func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.startCamera()
        state = .camera

      case .streamingStarted:
        buttonState = .initial

      case .docRecordingStarted:
        // The SDK does not have an event to notify the record of one side, so we use a Timer to flip the overlay and indicate the user to turn its document
        if buttonState != .record {
          return
        }

        self.timer?.invalidate()
        self.timer = .scheduledTimer(withTimeInterval: self.recordDocumentTimeout / 2, repeats: false, block: { @MainActor _ in
          self.scanningState = .verso
        })

      default:
        break
      }
    }
  }
}

// MARK: AVBeamRecordDocumentDelegate

extension RecordDocumentViewModel: AVBeamRecordDocumentDelegate {
  nonisolated func didCompleteRecordDocument(packageResult: AVBeamPackageResult) {
    Task { @MainActor in
      do {
        guard packageResult.data.errorCode == .none else {
          return self.handleError(packageResult.data.errorCode)
        }

        self.buttonState = .loading

        try? avBeam.stopCamera()
        guard let caseId = self.context.caseId else { throw EIDRequestError.missingCaseId }
        let output = RecordDocumentOutput(packageResult)
        try await self.saveEIDRequestFilesUseCase.execute(output.files, forRequestCaseId: caseId)

        try? await Task.sleep(nanoseconds: scanDelay)
        self.buttonState = .success
        try? await Task.sleep(nanoseconds: scanDelay)

        self.destination = .avIntroSelfieVideo
      } catch {
        self.handleError(error)
      }
    }
  }
}

// MARK: - Error Handling

extension RecordDocumentViewModel {

  private func handleError(_ error: Error) {
    analytics.log(error)
    reset()
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
      guard let self else { return }
      reset()
      navigator.returnToCheckpointSafely(EIDRequestCheckpoints.recordDocumentInformation)
    }
  }
}
