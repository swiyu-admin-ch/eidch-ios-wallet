import BITAVWrapper
import BITL10n
import BITNetworking
import Factory
import Foundation
import SwiftUI

// MARK: - RecordDocumentViewModel

@MainActor
class RecordDocumentViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router

    avBeam.messageDelegate = self
    avBeam.recordDocumentDelegate = self

    if avBeam.state == AVBeamState.initialized {
      state = .ready
    }
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

  enum StateView {
    case sdkInitializing
    case ready
    case error(_ error: Error)
  }

  @Published var state = StateView.sdkInitializing
  @Published var introductionPopupState: ScanningState? = .recto
  @Published var isNotificationPresented = false
  @Published var notification: AVBeamNotification? = nil
  @Published var timer: Timer?

  @Injected(\.avBeam) var avBeam: AVBeamProtocol

  @Published var scanningState = ScanningState.recto {
    didSet {
      introductionPopupState = scanningState
    }
  }

  var overlayImage: (front: Image, back: Image) {
    let image: (ImageAsset, ImageAsset) = switch router.context.identityType {
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
      guard let caseId = router.context.caseId else { return }

      let requestCase = try await fetchEIDRequestCaseUseCase.execute(caseId: caseId)
      router.context.identityType = requestCase.selectedDocumentType
    } catch {
      handleError(error)
    }
  }

  func initializeSDK() {
    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      handleError(error)
    }
  }

  func stop() {
    avBeam.stopRecordDocument()
    avBeam.shutdown()
  }

  func startRecordDocument() async {
    Task {
      do {
        let config = AVBeamRecordDocumentConfig(timeout: recordDocumentTimeout)
        try avBeam.startRecordDocument(config: config)
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
    introductionPopupState = nil
  }

  // MARK: Private

  private var router: EIDRequestInternalRoutes

  @Injected(\.saveEIDRequestFilesUseCase) private var saveEIDRequestFilesUseCase
  @Injected(\.recordDocumentTimeout) private var recordDocumentTimeout
  @Injected(\.fetchEIDRequestCaseUseCase) private var fetchEIDRequestCaseUseCase
  @Injected(\.avBeamAppID) private var avBeamAppID

  private func handleError(_ error: Error) {
    state = .error(error)
  }

}

// MARK: AVBeamMessageDelegate

@MainActor
extension RecordDocumentViewModel: AVBeamMessageDelegate {

  func didReceiveError(error: AVBeamError) {}

  func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.state = .ready
      case .docRecordingStarted:
        timer = .scheduledTimer(withTimeInterval: recordDocumentTimeout / 2, repeats: false, block: { @MainActor _ in
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

  func didCompleteRecordDocument(packageResult: AVBeamPackageResult) {
    Task { @MainActor in
      do {
        guard let caseId = router.context.caseId else { throw EIDRequestError.missingCaseId }
        let output = RecordDocumentOutput(packageResult)
        try await saveEIDRequestFilesUseCase.execute(output.files, forRequestCaseId: caseId)

        DispatchQueue.main.asyncAfter(deadline: .now()) {
          self.router.avIntroSelfieVideo()
        }
      } catch {
      }
    }

  }

}
