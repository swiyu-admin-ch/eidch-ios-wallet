import AVFoundation
import SwiftUI

class DocumentSelectionViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, cameraPermission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)) {
    self.router = router
    self.cameraPermission = cameraPermission

  }

  // MARK: Internal

  func didSelect(_ type: IdentityType) {
    router.context.identityType = type

    switch cameraPermission {
    case .authorized:
      router.scanDocument()
    default:
      router.cameraPermission()
    }
  }

  func mrzMockData() {
    router.mrzMockData()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
  private let cameraPermission: AVAuthorizationStatus
}
