import BITCore
import Foundation

// MARK: - NonComplianceReasonDisplay

public struct NonComplianceReasonDisplay: Codable, Equatable, DisplayLocalizable, Sendable {

  // MARK: Lifecycle

  public init(locale: UserLocale?, reason: String) {
    self.locale = locale
    self.reason = reason
  }

  // MARK: Public

  public let locale: UserLocale?
  public let reason: String
}
