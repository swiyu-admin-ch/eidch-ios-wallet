import Foundation

public enum ActorTrust: String, Codable, Equatable, Sendable {
  case trusted
  case untrusted
  case trustedCheckApp
  case unknown
}
