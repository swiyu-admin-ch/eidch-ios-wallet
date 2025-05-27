import XCTest
@testable import BITCore

// MARK: - DisplayLocalizableTests

final class DisplayLocalizableTests: XCTestCase {

  /// Search a display available in the preferred languages
  func testWhenDisplayAvailableInPreferredLanguage() {
    let displays = [
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissItalian.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue),
    ]

    let preferredLanguageCodes = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.german.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.italian.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.english.rawValue),
    ]

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNotNil(display)
    XCTAssertEqual(UserLocale.LocaleIdentifier.swissGerman.rawValue, display?.locale)
  }

  /// Search a display NOT available in the preferred languages --> returns default language (EN)
  func testWhenDisplayIsNotAvailableInPreferredLanguage_ReturnsFallbackLanguage() {
    let displays = [
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissEnglish.rawValue),
    ]

    let preferredLanguageCodes = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.italian.rawValue),
    ]

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNotNil(display)
    XCTAssertEqual(UserLocale.LocaleIdentifier.swissEnglish.rawValue, display?.locale)
  }

  /// Search a display NOT available in the preferred languages, NOT available in default language (EN) --> returns first
  func testWhenDisplayIsNotAvailableInPreferredLanguageAndNotDefaultLanguage_ReturnsFirstLanguage() {
    let displays = [
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissItalian.rawValue),
    ]

    let preferredLanguageCodes: [UserLanguageCode] = []

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNotNil(display)
    XCTAssertEqual(UserLocale.LocaleIdentifier.swissFrench.rawValue, display?.locale)
  }

  func testWhenDisplaysAreEmpty_ReturnsNil() {
    let displays: [MockDisplay] = []
    let preferredLanguageCodes: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.italian.rawValue),
    ]

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNil(display)
  }

  func testWhenDisplayIsSentAsLanguageIdentifier() {
    let displays = [
      MockDisplay(locale: UserLocale.LanguageIdentifier.italian.rawValue),
      MockDisplay(locale: UserLocale.LanguageIdentifier.german.rawValue),
      MockDisplay(locale: UserLocale.LanguageIdentifier.french.rawValue),
    ]

    let preferredLanguageCodes = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.german.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.italian.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.english.rawValue),
    ]

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNotNil(display)
    XCTAssertEqual(UserLocale.LanguageIdentifier.german.rawValue, display?.locale)
  }
}

// MARK: - MockDisplay

fileprivate struct MockDisplay: DisplayLocalizable {
  var locale: UserLocale?
}
