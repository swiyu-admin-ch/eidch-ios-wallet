import Foundation

public enum ActorComplianceStatus: String, Codable, Equatable, Sendable {
  case compliant
  case notCompliant
  case unknown
}
