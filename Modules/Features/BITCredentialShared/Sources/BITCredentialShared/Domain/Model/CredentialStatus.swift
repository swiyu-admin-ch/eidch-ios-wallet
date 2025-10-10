import BITEntities
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

  // MARK: Lifecycle

  init(_ status: VerifiableCredentialEntity.CredentialStatus) {
    switch status {
    case .valid:
      self = .valid
    case .revoked:
      self = .revoked
    case .suspended:
      self = .suspended
    case .expired:
      self = .expired
    case .notYetValid:
      self = .notYetValid
    case .unsupported:
      self = .unsupported
    case .unknown:
      self = .unknown
    }
  }
}

extension VerifiableCredentialEntity.CredentialStatus {

  init(_ status: CredentialStatus) {
    switch status {
    case .valid:
      self = .valid
    case .revoked:
      self = .revoked
    case .suspended:
      self = .suspended
    case .expired:
      self = .expired
    case .notYetValid:
      self = .notYetValid
    case .unsupported:
      self = .unsupported
    case .unknown:
      self = .unknown
    }
  }
}
