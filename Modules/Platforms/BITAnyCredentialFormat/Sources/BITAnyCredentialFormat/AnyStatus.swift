import Foundation
import Spyable

// MARK: - AnyStatus

@Spyable
public protocol AnyStatus {
  var type: AnyStatusType { get }
}

// MARK: - AnyStatusType

public enum AnyStatusType: String, Sendable {
  case tokenStatusList
}
