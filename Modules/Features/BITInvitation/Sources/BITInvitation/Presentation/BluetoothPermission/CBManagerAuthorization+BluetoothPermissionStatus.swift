import CoreBluetooth

extension CBManagerAuthorization {
  var permissionStatus: BluetoothPermissionStatus {
    switch self {
    case .allowedAlways: .authorized
    case .denied: .goToSettings
    case .restricted: .goToSettings
    case .notDetermined: .requestPermission
    @unknown default: .goToSettings
    }
  }
}
