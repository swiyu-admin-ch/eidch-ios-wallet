import Factory
import Foundation

// MARK: - JWT

// https://www.rfc-editor.org/rfc/rfc7519

public protocol JWT: Codable, Equatable {
  var type: String? { get }
  var issuer: String? { get }
  var audience: String? { get }
  var subject: String? { get }
  var issuedAt: Date? { get }
  var expiredAt: Date? { get }
  var activatedAt: Date? { get }
  var isExpired: Bool { get }
}

extension JWT {

  public var isExpired: Bool {
    guard let expiredAt else {
      return false
    }

    return Container.shared.currentDate() > expiredAt
  }
}
