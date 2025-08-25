import BITAVWrapper
import BITL10n
import BITNetworking
import Factory
import Foundation
import SwiftUI

// MARK: - ScanDocumentViewModel

@MainActor
class ScanDocumentViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router

    avBeam.messageDelegate = self
    avBeam.scanDocumentDelegate = self

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

  enum StateView {
    case sdkInitializing
    case ready
    case error(_ error: Error)
  }

  @Published var state = StateView.sdkInitializing
  @Published var introductionPopupState: ScanningState? = .recto
  @Published var isNotificationPresented = false
  @Published var notification: AVBeamNotification? = nil

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

  func initializeSDK() {
    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      handleError(error)
    }
  }

  func stop() {
    avBeam.stopScanDocument()
    avBeam.shutdown()
  }

  func startCamera() async {
    Task {
      do {
        try avBeam.startCamera()
      } catch {
        handleError(error)
      }
    }
  }

  func startScan(frame: CGRect) async {
    Task {
      do {
        let config = AVBeamScanDocumentConfig(scanFrame: frame, timeout: 15)
        try avBeam.startScanDocument(config: config)
      } catch {
        handleError(error)
      }
    }
  }

  func close() {
    stop()
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

  @Injected(\.avBeamAppID) private var avBeamAppID

  private func handleError(_ error: Error) {
    state = .error(error)
  }

}

// MARK: AVBeamMessageDelegate

extension ScanDocumentViewModel: AVBeamMessageDelegate {

  func didReceiveError(error: AVBeamError) {}

  func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.state = .ready

      case .idDocMatched,
           .idDocNotMatched:
        break

      case .idDetectionDone:
        self.isNotificationPresented = false
        self.notification = nil
        introductionPopupState = nil

      case .idRecognitionStopped:
        self.isNotificationPresented = false
        self.notification = nil

      case .idNeedSecondPageForMatching:
        scanningState = .verso

      default:
        self.isNotificationPresented = true
        self.notification = notification
      }
    }
  }
}

// MARK: AVBeamScanDocumentDelegate

extension ScanDocumentViewModel: AVBeamScanDocumentDelegate {

  func didCompleteScanDocument(packageResult: AVBeamPackageResult) {
    Task { @MainActor in
      do {
        let output = try ScanDocumentOutput(packageResult, identityType: router.context.identityType ?? .identityCard)
        router.scanDocumentSubmit(output)
      } catch {
      }
    }
  }

}
