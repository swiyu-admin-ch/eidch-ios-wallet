import AVFoundation

public enum CameraPermissionStatus {
  case authorized
  case restricted
  case denied
  case notDetermined

  // MARK: Internal

  static var isCameraPermissionAuthorized: Bool {
    cameraPermissionStatus == .authorized
  }

  static var cameraPermissionStatus: CameraPermissionStatus {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      return .authorized
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    @unknown default:
      return .denied
    }
  }
}
