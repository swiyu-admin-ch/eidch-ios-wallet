import BITCore
import Foundation

// MARK: - NonComplianceReasonDisplay

public struct NonComplianceReasonDisplay: Codable, Equatable, DisplayLocalizable {

  // MARK: Lifecycle

  public init(locale: UserLocale?, value: String) {
    self.locale = locale
    self.value = value
  }

  // MARK: Public

  public let locale: UserLocale?
  public let value: String
}
