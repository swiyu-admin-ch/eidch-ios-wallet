import CoreBluetooth
import Foundation
import Spyable

// MARK: - RequestBluetoothPermissionUseCaseProtocol

@Spyable
protocol RequestBluetoothPermissionUseCaseProtocol {
  func callAsFunction() -> AsyncStream<BluetoothPermissionStatus>
}

// MARK: - RequestBluetoothPermissionUseCase

/// `CBCentralManager` is created with `queue: nil`, so every delegate callback and therefore every
/// mutation of `bluetoothManager` / `continuation` happens on the main queue. The only consumer is a
/// SwiftUI view modifier, which is main-actor isolated too. That confinement is what makes the
/// unchecked conformance sound; it is required because `onTermination` is a `@Sendable` closure.
final class RequestBluetoothPermissionUseCase: NSObject, RequestBluetoothPermissionUseCaseProtocol, @unchecked Sendable {

  // MARK: Internal

  func callAsFunction() -> AsyncStream<BluetoothPermissionStatus> {
    AsyncStream { continuation in
      self.continuation?.finish()
      self.continuation = continuation

      if bluetoothManager == nil {
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
      } else {
        bluetoothManager?.delegate = self
      }

      continuation.onTermination = { [weak self] _ in
        self?.continuation = nil
      }
    }
  }

  // MARK: Private

  private var bluetoothManager: CBCentralManager?
  private var continuation: AsyncStream<BluetoothPermissionStatus>.Continuation?
}

// MARK: CBCentralManagerDelegate

extension RequestBluetoothPermissionUseCase: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    let status = central.state.permissionStatus ?? CBManager.authorization.permissionStatus
    continuation?.yield(status)

    if status != .requestPermission {
      continuation?.finish()
      continuation = nil
    }
  }
}
