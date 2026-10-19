import Foundation

// MARK: - VcStatus

public enum VcStatus: String, Codable, CaseIterable, Sendable {
  case valid
  case revoked
  case suspended
  case unsupported
  case unknown
}
