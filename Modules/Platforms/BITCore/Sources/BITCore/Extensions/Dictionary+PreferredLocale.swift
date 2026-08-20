import Foundation

extension Dictionary where Key == UserLocale {

  public func findValue(considering locales: [UserLocale], fallback: Value?) -> Value? {
    for locale in locales {
      if let exactMatch = self[locale] {
        return exactMatch
      }
      if let match = first(where: { key, _ in key.hasSameLanguage(locale) }) {
        return match.value
      }
    }

    return self[""] ?? fallback
  }
}

extension String {
  fileprivate var language: UserLanguageCode? {
    split(separator: "-").first.map(String.init)
  }

  fileprivate var hasRegion: Bool {
    contains("-")
  }

  fileprivate func hasSameLanguage(_ locale: UserLocale) -> Bool {
    guard
      let languageCode = locale.language,
      let keyLanguage = language,
      keyLanguage == languageCode
    else { return false }
    return !hasRegion || !locale.hasRegion
  }
}
