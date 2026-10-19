import Foundation
import Spyable

// MARK: - Loggable

public protocol Loggable: Sendable {
  func log(_ event: AnalyticsEventProtocol)
  func log(_ errorEvent: AnalyticsErrorEventProtocol)
  func log(_ error: Error)
}
