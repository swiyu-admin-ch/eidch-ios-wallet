import BITCore
import Factory
import Foundation
import RealmSwift

extension List where Element: DisplayLocalizable {

  // MARK: Public

  /// 1. User Preferred Languages
  /// 2. Default App Language
  /// 3. First available language
  /// 4. Nil
  public func findDisplayWithFallback(preferredLanguageCodes: [UserLanguageCode] = Container.shared.preferredUserLanguageCodes()) -> Element? {
    findDisplaysWithFallback(preferredLanguageCodes: preferredLanguageCodes).first
  }

  public func findDisplaysWithFallback(
    preferredLanguageCodes: [UserLanguageCode] = Container.shared.preferredUserLanguageCodes())
    -> [Element]
  {
    preferredLanguageCodes
      .lazy
      .map { code in
        self.filter { display in
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
    let emptyMatches = filter { $0.locale == "" }
    if !emptyMatches.isEmpty {
      return Array(emptyMatches)
    }

    guard let locale = first?.locale else { return [] }
    return findDisplaysWithFallback(preferredLanguageCodes: [locale])
  }
}
