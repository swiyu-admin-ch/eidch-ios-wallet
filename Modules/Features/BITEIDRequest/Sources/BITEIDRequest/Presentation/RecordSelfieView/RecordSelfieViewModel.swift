import BITAVWrapper
import BITL10n
import BITNetworking
import Factory
import Foundation
import SwiftUI

// MARK: - RecordSelfieViewModel

@MainActor
class RecordSelfieViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router

    avBeam.messageDelegate = self
    avBeam.captureFaceDelegate = self

    if avBeam.state == AVBeamState.initialized {
      state = .ready
    }
  }

  // MARK: Internal

  enum StateView {
    case sdkInitializing
    case ready
    case error(_ error: Error)
  }

  @Published var state = StateView.sdkInitializing
  @Published var isNotificationPresented = false
  @Published var isIntroductionPopupPresented = true
  @Published var notification: AVBeamNotification? = nil

  @Injected(\.avBeam) var avBeam: AVBeamProtocol

  func initializeSDK() {
    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      handleError(error)
    }
  }

  func stop() {
    avBeam.stopCaptureFace()
    avBeam.shutdown()
  }

  func startRecordSelfie() async {
    Task(priority: .background) {
      do {
        let config = AVBeamCaptureFaceConfig(files: [], duration: recordSelfieTimeout)
        try avBeam.startCaptureFace(config: config)
      } catch {
        handleError(error)
      }
    }
  }

  func close() {
    stop()
    router.close()
  }

  func closeIntroductionPopup() {
    isIntroductionPopupPresented = false
  }

  // MARK: Private

  private var router: EIDRequestInternalRoutes

  @Injected(\.saveEIDRequestFilesUseCase) private var saveEIDRequestFilesUseCase
  @Injected(\.recordSelfieTimeout) private var recordSelfieTimeout
  @Injected(\.avBeamAppID) private var avBeamAppID

  private func handleError(_ error: Error) {
    state = .error(error)
  }

}

// MARK: AVBeamMessageDelegate

@MainActor
extension RecordSelfieViewModel: AVBeamMessageDelegate {

  func didReceiveError(error: AVBeamError) {}

  func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.state = .ready
      case .streamingStarted:
        break
      case .faceCapturingStopped:
        isNotificationPresented = false
        self.notification = nil
        isIntroductionPopupPresented = false
      case .faceCaptureTiltSmile,
           .faceCapturingStarted:
        isNotificationPresented = true
        self.notification = notification
      default:
        self.isNotificationPresented = true
        self.notification = notification
      }
    }
  }
}

// MARK: AVBeamCaptureFaceDelegate

extension RecordSelfieViewModel: AVBeamCaptureFaceDelegate {

  func didCompleteCaptureFace(packageResult: AVBeamPackageResult) {
    Task { @MainActor in
      do {
        guard let caseId = router.context.caseId else { throw EIDRequestError.missingCaseId }
        let output = RecordSelfieOutput(packageResult)
        try await saveEIDRequestFilesUseCase.execute(output.files, forRequestCaseId: caseId)

        self.router.submitEidRequest()
      } catch {
      }
    }
  }

}
