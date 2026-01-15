import Foundation
import Moya

// MARK: - TimeoutConfigurable

/// Protocol for endpoints that need custom timeout configuration
public protocol TimeoutConfigurable {
  var timeoutInterval: TimeInterval { get }
}

// MARK: - TargetType + Timeout

extension TargetType {
  /// Default timeout interval. Override by conforming to TimeoutConfigurable.
  public var defaultTimeoutInterval: TimeInterval? {
    (self as? TimeoutConfigurable)?.timeoutInterval
  }
}
