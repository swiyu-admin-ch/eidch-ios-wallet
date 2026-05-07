import BITAnalytics
import BITAVWrapper
import BITL10n
import BITNavigation
import BITNetworking
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - RecordSelfieViewModel

@MainActor
@Observable
final class RecordSelfieViewModel {

  // MARK: Lifecycle

  init() {
    avBeam.messageDelegate = self
    avBeam.captureFaceDelegate = self
  }

  // MARK: Internal

  enum StateView: Equatable {
    case loading
    case camera
  }

  var state = StateView.loading
  var buttonState = RecordingButton.State.initial
  var isNotificationPresented = false
  var notification: AVBeamNotification?

  @ObservationIgnored @Injected(\.avBeam) var avBeam: AVBeamProtocol

  var destination: EIDRequestDestinations?

  var buttonStateAccessibilityLabel: String {
    switch buttonState {
    case .initial: L10n.tkEidRequestRecordSelfieButtonInitialStateAlt
    case .record: L10n.tkEidRequestRecordSelfieButtonRecordStateAlt
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

  func startCamera() {
    let avBeam = avBeam
    Task.detached { [weak self] in
      do {
        try avBeam.startFrontCamera()
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

  func startRecordSelfie() {
    do {
      let inputFile = try updateInputFileUseCase()
      let config = AVBeamCaptureFaceConfig(files: [inputFile], duration: recordSelfieTimeout)
      let avBeam = avBeam

      buttonState = .record

      Task.detached { [weak self] in
        do {
          try avBeam.startCaptureFace(config: config)
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

  func stop() {
    avBeam.stopCaptureFace()
    try? avBeam.stopCamera()
  }

  func stopRecordSelfie() {
    reset()
    avBeam.stopCaptureFace()
  }

  func cancelInitialization(_ navigator: Navigator) {
    avBeam.shutdown()
    navigator.returnToCheckpointSafely(EIDRequestCheckpoints.recordSelfieInformation)
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.eidRequestContext) private var context

  @ObservationIgnored @Injected(\.saveEIDRequestFilesUseCase) private var saveEIDRequestFilesUseCase
  @ObservationIgnored @Injected(\.recordSelfieTimeout) private var recordSelfieTimeout
  @ObservationIgnored @Injected(\.avBeamAppID) private var avBeamAppID
  @ObservationIgnored @Injected(\.scanDelay) private var scanDelay
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator
  @ObservationIgnored @Injected(\.updateInputFileUseCase) private var updateInputFileUseCase: UpdateInputFileUseCaseProtocol

  private func reset() {
    isNotificationPresented = false
    notification = nil
    buttonState = .initial
  }

  private func stopCamera() throws {
    avBeam.stopCaptureFace()
    try avBeam.stopCamera()
  }
}

// MARK: AVBeamMessageDelegate

extension RecordSelfieViewModel: AVBeamMessageDelegate {

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
      case .faceCapturingStopped:
        self.isNotificationPresented = false
        self.notification = nil
      case .faceCapturingStarted:
        buttonState = .record
      default:
        self.isNotificationPresented = true
        self.notification = notification
      }
    }
  }
}

// MARK: AVBeamCaptureFaceDelegate

extension RecordSelfieViewModel: AVBeamCaptureFaceDelegate {
  nonisolated func didCompleteCaptureFace(packageResult: AVBeamPackageResult) {
    Task { @MainActor in
      guard packageResult.data.errorCode == .none else {
        return self.handleError(packageResult.data.errorCode)
      }

      self.buttonState = .loading

      do {
        guard let caseId = self.context.caseId else { throw EIDRequestError.missingCaseId }
        let output = RecordSelfieOutput(packageResult)
        try await self.saveEIDRequestFilesUseCase.execute(output.files, forRequestCaseId: caseId)

        try? await Task.sleep(nanoseconds: scanDelay)
        self.buttonState = .success
        try? await Task.sleep(nanoseconds: scanDelay)

        try stopCamera()
        self.destination = .submitEidRequest
      } catch {
        self.handleError(error)
      }
    }
  }
}

// MARK: - Error Handling

extension RecordSelfieViewModel {

  private func handleError(_ error: Error) {
    analytics.log(error)
    stop()
    destination = .error(errorDataset(for: error))
  }

  private func retryAction(_ navigator: Navigator) {
    reset()
    startCamera()
    navigator.pop()
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
      navigator.returnToCheckpointSafely(EIDRequestCheckpoints.recordSelfieInformation)
    }
  }
}
