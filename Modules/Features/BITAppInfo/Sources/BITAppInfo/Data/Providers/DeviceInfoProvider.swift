import DeviceKit
import Spyable

// MARK: - DeviceInfoProviderProtocol

@Spyable
protocol DeviceInfoProviderProtocol {
  var systemVersion: Version? { get }
  var modelDescription: String { get }
}

// MARK: - DeviceInfoProvider

struct DeviceInfoProvider: DeviceInfoProviderProtocol {

  var systemVersion: Version? {
    guard let systemVersion = Device.current.systemVersion else {
      return nil
    }

    return Version(systemVersion)
  }

  var modelDescription: String {
    Device.current.description
  }

}
