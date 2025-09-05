import Factory
import Foundation

// MARK: - DisplayLocalizable

public protocol DisplayLocalizable {
  var locale: UserLocale? { get }
}

// MARK: - DisplayLocalizableError

enum DisplayLocalizableError: Error {
  case displayNotFound
}

extension Array where Element: DisplayLocalizable {

  // MARK: Public

  /// 1. User Preferred Languages
  /// 2. Default App Language
  /// 3. First available language
  /// 4. Nil
  public func findDisplayWithFallback(preferredLanguageCodes: [UserLanguageCode] = Container.shared.preferredUserLanguageCodes()) -> Element? {
    findDisplaysWithFallback(preferredLanguageCodes: preferredLanguageCodes).first
  }

  public func findDisplaysWithFallback(
    preferredLanguageCodes: [UserLanguageCode] = Container.shared.preferredUserLanguageCodes()
  ) -> [Element] {
    preferredLanguageCodes
      .lazy
      .map { code in
        filter { display in
          display.locale?.hasPrefix("\(code)") == true
        }
      }
      .first(where: { preferredDisplays in
        !preferredDisplays.isEmpty
      })
      ?? getFallbackDisplays()
  }

  // MARK: Private

  private func getFallbackDisplays() -> [Element] {
    guard let locale = first?.locale else { return [] }
    return findDisplaysWithFallback(preferredLanguageCodes: [locale])
  }
}
