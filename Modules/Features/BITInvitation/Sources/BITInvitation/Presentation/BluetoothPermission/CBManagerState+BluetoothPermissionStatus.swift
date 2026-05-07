import CoreBluetooth

extension CBManagerState {
  var permissionStatus: BluetoothPermissionStatus? {
    switch self {
    case .poweredOff,
         .unsupported:
      .goToSettings
    default:
      nil
    }
  }
}
