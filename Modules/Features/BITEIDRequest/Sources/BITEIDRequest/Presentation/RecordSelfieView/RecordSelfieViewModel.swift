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
class RecordSelfieViewModel: ObservableObject {

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

  @Published var state = StateView.loading
  @Published var buttonState = RecordingButton.State.initial
  @Published var isNotificationPresented = false
  @Published var notification: AVBeamNotification? = nil

  @Injected(\.avBeam) var avBeam: AVBeamProtocol

  @Published var destination: EIDRequestDestinations?

  func initializeSDK() {
    if avBeam.state == .initialized {
      startCamera()
      return
    }

    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      handleError(error)
    }
  }

  func stop() {
    avBeam.stopCaptureFace()
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
    let config = AVBeamCaptureFaceConfig(files: [], duration: recordSelfieTimeout)
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
  }

  func stopRecordSelfie() {
    reset()
    stop()
  }

  func cancelInitialization() {
    avBeam.shutdown()
    navigatorRoot.returnToCheckpoint(EIDRequestCheckpoints.recordSelfieInformation)
  }

  // MARK: Private

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.eidRequestContext) private var context

  @Injected(\.saveEIDRequestFilesUseCase) private var saveEIDRequestFilesUseCase
  @Injected(\.recordSelfieTimeout) private var recordSelfieTimeout
  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.navigatorRoot) private var navigatorRoot
  @Injected(\.scanDelay) private var scanDelay

  private func handleError(_ error: Error) {
    analytics.log(error)
    stop()
    destination = .error(.retry(error, { [weak self] navigator in
      self?.reset()
      self?.startCamera()
      navigator.pop()
    }))
  }

  private func reset() {
    isNotificationPresented = false
    notification = nil
    buttonState = .initial
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

        self.stop()
        try? avBeam.stopCamera()
        self.destination = .submitEidRequest
      } catch {
        self.handleError(error)
      }
    }
  }

}
