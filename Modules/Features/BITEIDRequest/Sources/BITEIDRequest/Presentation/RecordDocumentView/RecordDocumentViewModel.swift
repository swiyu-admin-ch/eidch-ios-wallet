import BITAVWrapper
import BITL10n
import BITNavigation
import BITNetworking
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - RecordDocumentViewModel

@MainActor
class RecordDocumentViewModel: ObservableObject {

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

  @Published var state = StateView.loading
  @Published var introductionPopupState: ScanningState? = .recto
  @Published var isNotificationPresented = false
  @Published var notification: AVBeamNotification? = nil
  @Published var timer: Timer?

  @Published var destination: EIDRequestDestinations?

  @Injected(\.avBeam) var avBeam: AVBeamProtocol

  @Published var scanningState = ScanningState.recto {
    didSet {
      introductionPopupState = scanningState
    }
  }

  var overlayImage: (front: Image, back: Image) {
    let image: (ImageAsset, ImageAsset) = switch context.identityType {
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

  func setup() async {
    do {
      guard let caseId = context.caseId else { return }

      let requestCase = try await fetchEIDRequestCaseUseCase.execute(caseId: caseId)
      context.identityType = .identityCard

      initializeSDK()
    } catch {
      handleError(error)
    }
  }

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
    avBeam.stopRecordDocument()
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

  func startRecordDocument() {
    let config = AVBeamRecordDocumentConfig(timeout: recordDocumentTimeout)
    let avBeam = avBeam
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
  }

  func closeIntroductionPopup() {
    introductionPopupState = nil
  }

  // MARK: Private

  @Injected(\.saveEIDRequestFilesUseCase) private var saveEIDRequestFilesUseCase
  @Injected(\.recordDocumentTimeout) private var recordDocumentTimeout
  @Injected(\.fetchEIDRequestCaseUseCase) private var fetchEIDRequestCaseUseCase
  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.eidRequestContext) private var context

  private func handleError(_ error: Error) {
    stop()
    destination = .error(.retry(error, { [weak self] navigator in
      self?.reset()
      self?.startCamera()
      navigator.pop()
    }))
  }

  private func reset() {
    scanningState = .recto
    isNotificationPresented = false
    notification = nil
  }
}

// MARK: AVBeamMessageDelegate

extension RecordDocumentViewModel: AVBeamMessageDelegate {

  nonisolated func didReceiveError(error: AVBeamError) {}

  nonisolated func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.startCamera()

      case .streamingStarted:
        self.startRecordDocument()

      case .docRecordingStarted:
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

        try? avBeam.stopCamera()
        guard let caseId = self.context.caseId else { throw EIDRequestError.missingCaseId }
        let output = RecordDocumentOutput(packageResult)
        try await self.saveEIDRequestFilesUseCase.execute(output.files, forRequestCaseId: caseId)
        self.destination = .avIntroSelfieVideo
      } catch {
        self.handleError(error)
      }
    }
  }

}
