import BITL10n

// MARK: - BluetoothPermissionStatus

enum BluetoothPermissionStatus: Equatable {
  case authorized
  case goToSettings
  case requestPermission
}

extension BluetoothPermissionStatus {
  var label: String {
    switch self {
    case .authorized,
         .goToSettings:
      L10n.tkGlobalTothesettings
    case .requestPermission:
      L10n.tkGlobalContinue
    }
  }
}
