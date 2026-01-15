import BITAVWrapper
import BITL10n
import BITNavigation
import BITNetworking
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI
import UIKit

// MARK: - ScanDocumentViewModel

@MainActor
class ScanDocumentViewModel: ObservableObject {

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

  @Published var state = StateView.loading
  @Published var introductionPopupState: ScanningState? = .recto
  @Published var isNotificationPresented = false
  @Published var notification: AVBeamNotification? = nil

  @Published var destination: EIDRequestDestinations?

  @Injected(\.avBeam) var avBeam: AVBeamProtocol

  var scanFrame = CGRect.zero

  var overlayImage: (front: Image, back: Image) {
    let image: (ImageAsset, ImageAsset) = switch context.identityType {
    case .passport:
      (Assets.Camera.passportFront, Assets.Camera.passportBack)
    default:
      (Assets.Camera.idFront, Assets.Camera.idBack)
    }
    return (image.0.swiftUIImage, image.1.swiftUIImage)
  }

  @Published var scanningState = ScanningState.recto {
    didSet {
      introductionPopupState = scanningState
    }
  }

  var title: String {
    scanningState.title
  }

  func initializeSDK() {
    if avBeam.state == .initialized {
      return startCamera()
    }

    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      handleError(error)
    }
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
    let config = AVBeamScanDocumentConfig(scanFrame: scanFrame, timeout: 15)
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
  }

  // MARK: Private

  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.eidRequestContext) private var context
  @Injected(\.compareScanDocumentOutputUseCase) private var compareScanDocumentOutputUseCase: CompareScanDocumentOutputUseCaseProtocol
  @Injected(\.updateEIDRequestCaseFilesUseCase) private var updateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocol

  private func handleError(_ error: Error) {
    stop()
    let dataset = ErrorDataset.retry(error) { [weak self] navigator in
      self?.reset()
      self?.startCamera()
      navigator.pop()
    }

    destination = .error(dataset)
  }

  private func reset() {
    scanningState = .recto
    isNotificationPresented = false
    notification = nil
  }

  private func handleScanDocumentOutput(_ output: ScanDocumentOutput) async throws {
    guard let caseId = context.caseId, let autoVerificationResponse = context.autoVerificationResponse else {
      return destination = .scanDocumentSubmit(output)
    }

    guard await compareScanDocumentOutputUseCase(for: caseId, with: output) else {
      let errorDataset = ErrorDataset([
        .title(L10n.tkEidRequestDocumentScanWrongDocumentPrimary),
        .body(L10n.tkEidRequestDocumentScanWrongDocumentSecondary),
      ], actions: [
        .primary(L10n.tkEidRequestDocumentScanWrongDocumentButton, { navigator in
          navigator.returnToCheckpoint(EIDRequestCheckpoints.scanDocumentInformation)
        }),
      ])

      return destination = .error(errorDataset)
    }

    try await updateEIDRequestCaseFilesUseCase(for: caseId, scanDocumentOutput: output)
    destination = autoVerificationResponse.isDocumentVideoRecordingRequired ? .recordDocumentInformation : .avIntroSelfieVideo
  }
}

// MARK: AVBeamMessageDelegate

extension ScanDocumentViewModel: AVBeamMessageDelegate {

  nonisolated func didReceiveError(error: AVBeamError) {}

  nonisolated func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.startCamera()

      case .idDocMatched,
           .idDocNotMatched:
        break

      case .streamingStarted:
        self.startScan()

      case .idDetectionDone:
        break

      case .idRecognitionStopped:
        break

      case .idNeedSecondPageForMatching:
        self.scanningState = .verso

      default:
        self.isNotificationPresented = true
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

        try? avBeam.stopCamera()
        self.isNotificationPresented = false
        self.notification = nil
        self.introductionPopupState = nil

        let output = try ScanDocumentOutput(packageResult, identityType: self.context.identityType ?? .identityCard)
        try await handleScanDocumentOutput(output)
      } catch {
        self.handleError(error)
      }
    }
  }

}
