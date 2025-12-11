import Factory
import Foundation

// MARK: - JWTValidityPayload

public protocol JWTValidityPayload: JWTPayload {
  var expiredAt: Date? { get }
  var activatedAt: Date? { get }
  var isExpired: Bool { get }
}

extension JWTValidityPayload {
  public var expiredAt: Date? {
    nil
  }

  public var activatedAt: Date? {
    nil
  }

  public var isExpired: Bool {
    guard let expiredAt else {
      return false
    }

    return Container.shared.currentDate() > expiredAt
  }
}
