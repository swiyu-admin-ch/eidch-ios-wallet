import AVFoundation
import BITCore
import BITL10n
import BITNavigation

@MainActor
class CameraPermissionViewModel: ObservableObject {

  // MARK: Lifecycle

  init(initialState: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video), router: EIDRequestInternalRoutes) {
    self.router = router
    cameraPermissionStatus = initialState

    if cameraPermissionStatus == .authorized {
      openScanDocument()
    }
  }

  // MARK: Internal

  var primary: String {
    switch cameraPermissionStatus {
    case .notDetermined: L10n.tkReceiveCameraaccessneeded1Title
    case .denied,
         .restricted: L10n.tkReceiveCameraaccessneeded3Title
    default: ""
    }
  }

  var secondary: String {
    switch cameraPermissionStatus {
    case .notDetermined: L10n.tkReceiveCameraaccessneeded1Body
    case .denied,
         .restricted: L10n.tkReceiveCameraaccessneeded3Body
    default: ""
    }
  }

  var buttonAction: () -> Void {
    switch cameraPermissionStatus {
    case .notDetermined: { Task { await self.allowCamera() } }
    case .denied,
         .restricted: { self.openSettings() }
    default: { }
    }
  }

  var buttonText: String {
    switch cameraPermissionStatus {
    case .notDetermined: L10n.tkGlobalContinue
    case .denied,
         .restricted: L10n.tkGlobalTothesettings
    default: ""
    }
  }

  func allowCamera() async {
    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
    let status = await AVCaptureDevice.requestAccess(for: .video)
    NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
    cameraPermissionStatus = status ? .authorized : .denied

    if status {
      openScanDocument()
    }
  }

  func openSettings() {
    router.settings()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private var router: EIDRequestInternalRoutes
  @Published private var cameraPermissionStatus: AVAuthorizationStatus

  private func openScanDocument() {
    router.scanDocument()
  }

}
