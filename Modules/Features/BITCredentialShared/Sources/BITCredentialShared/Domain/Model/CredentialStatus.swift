import BITEntities
import Foundation

// MARK: - CredentialStatus

public enum CredentialStatus: String, Codable, CaseIterable {
  case valid
  case revoked
  case suspended
  case expired
  case businessExpired
  case notYetValid
  case unsupported
  case unknown

  // MARK: Lifecycle

  init(_ status: BundleItemEntity.CredentialStatus) {
    switch status {
    case .valid:
      self = .valid
    case .revoked:
      self = .revoked
    case .suspended:
      self = .suspended
    case .expired:
      self = .expired
    case .businessExpired:
      self = .businessExpired
    case .notYetValid:
      self = .notYetValid
    case .unsupported:
      self = .unsupported
    case .unknown:
      self = .unknown
    }
  }
}

extension BundleItemEntity.CredentialStatus {

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
    case .businessExpired:
      self = .businessExpired
    case .notYetValid:
      self = .notYetValid
    case .unsupported:
      self = .unsupported
    case .unknown:
      self = .unknown
    }
  }
}
