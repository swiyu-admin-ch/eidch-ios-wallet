import Foundation

// MARK: - JWTValidityPayload

public protocol JWTValidityPayload: JWTPayload {
  var expiredAt: Date? { get }
  var activatedAt: Date? { get }
}

extension JWTValidityPayload {
  public var expiredAt: Date? {
    nil
  }

  public var activatedAt: Date? {
    nil
  }
}
