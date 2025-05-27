import Foundation

// MARK: - CredentialStatus

public enum CredentialStatus: String, Codable, CaseIterable {
  case valid
  case revoked
  case suspended
  case expired
  case notYetValid
  case unsupported
  case unknown
}
