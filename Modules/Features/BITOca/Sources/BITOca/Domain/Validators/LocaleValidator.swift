import Foundation
import Spyable

// MARK: - LocaleValidatorProtocol

@Spyable
public protocol LocaleValidatorProtocol: Sendable {
  func validate(_ locale: String) -> Bool
}

// MARK: - LocaleValidator

struct LocaleValidator: LocaleValidatorProtocol {

  func validate(_ locale: String) -> Bool {
    let match = try? Self.languageRegex.wholeMatch(in: locale)
    return match != nil
  }

  private nonisolated(unsafe) static let languageRegex = #/^[a-z]{2}(-[A-Z]{2})?$/#
}
