import Foundation

public enum ActorTrust: String, Codable, Equatable {
  case trusted
  case untrusted
  case trustedCheckApp
  case unknown
}
