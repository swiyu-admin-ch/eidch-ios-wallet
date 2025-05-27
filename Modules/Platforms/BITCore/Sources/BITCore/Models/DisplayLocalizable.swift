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

  /// 1. User Preferred Languages
  /// 2. Default App Language
  /// 3. First available language
  /// 4. Nil
  public func findDisplayWithFallback(preferredLanguageCodes: [UserLanguageCode] = Container.shared.preferredUserLanguageCodes()) -> DisplayLocalizable? {
    for preferredLanguageCode in preferredLanguageCodes {
      if
        let requestedDisplay = first(where: { element in
          guard let locale = element.locale else {
            return false
          }

          return locale.starts(with: "\(preferredLanguageCode)")
        })
      {
        return requestedDisplay
      }
    }

    if
      let defaultAppLanguageDisplay = first(where: { element in
        guard let locale = element.locale else {
          return false
        }

        return locale.starts(with: "\(UserLanguageCode.defaultAppLanguageCode)")
      })
    {
      return defaultAppLanguageDisplay
    }

    return first
  }

}
