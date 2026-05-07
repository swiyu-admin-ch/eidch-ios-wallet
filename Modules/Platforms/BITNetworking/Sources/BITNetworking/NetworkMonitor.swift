import Factory
import Foundation
import Network

// MARK: - NetworkMonitorProtocol

@MainActor
public protocol NetworkMonitorProtocol: AnyObject {
  var isActive: Bool { get }
  var connectionType: NWInterface.InterfaceType { get }
}

// MARK: - NetworkMonitor

@MainActor
@Observable
public class NetworkMonitor: NetworkMonitorProtocol {

  // MARK: Lifecycle

  public init(connectionTypes: [NWInterface.InterfaceType] = NetworkContainer.shared.connectionTypes()) {
    monitor.pathUpdateHandler = { path in
      DispatchQueue.main.async {
        self.isActive = path.status == .satisfied

        let connectionTypes: [NWInterface.InterfaceType] = connectionTypes
        self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
      }
    }

    monitor.start(queue: queue)
  }

  // MARK: Public

  public var isActive = false
  public var connectionType = NWInterface.InterfaceType.other

  // MARK: Private

  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkMonitor")

}
