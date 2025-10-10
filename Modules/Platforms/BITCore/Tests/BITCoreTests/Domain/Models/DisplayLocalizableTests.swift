import XCTest
@testable import BITCore

// MARK: - DisplayLocalizableTests

final class DisplayLocalizableTests: XCTestCase {

  /// Search a display available in the preferred languages
  func testFindDisplayWithFallback_WhenDisplayAvailableInPreferredLanguage() {
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

  /// Search a display NOT available in the preferred languages --> returns first
  func testFindDisplayWithFallback_WhenDisplayIsNotAvailableInPreferredLanguage_ReturnsFirstLanguage() {
    let displays = [
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissItalian.rawValue),
    ]

    let preferredLanguageCodes = [UserLanguageCode]()

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNotNil(display)
    XCTAssertEqual(UserLocale.LocaleIdentifier.swissFrench.rawValue, display?.locale)
  }

  func testFindDisplayWithFallback_WhenDisplaysAreEmpty_ReturnsNil() {
    let displays = [MockDisplay]()
    let preferredLanguageCodes: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.italian.rawValue),
    ]

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNil(display)
  }

  func testFindDisplayWithFallback_WhenDisplayIsSentAsLanguageIdentifier() {
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

  func testFindDisplaysWithFallback_PreferredLanguagesReturnsMatchInOrder() {
    let displays = [
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissItalian.rawValue),
    ]
    let preferred: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.german.rawValue),
    ]

    let result = displays.findDisplaysWithFallback(preferredLanguageCodes: preferred)

    XCTAssertEqual(result.map(\.locale), [UserLocale.LocaleIdentifier.swissFrench.rawValue])
  }

  func testFindDisplaysWithFallback_WhenNoMatches_ReturnsAllMatchingLocaleOfFirst() {
    let displays = [
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissItalian.rawValue),
      MockDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
    ]
    let preferred: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
    ]

    let result = displays.findDisplaysWithFallback(preferredLanguageCodes: preferred)

    XCTAssertEqual(result.map(\.locale), [UserLocale.LocaleIdentifier.swissGerman.rawValue, UserLocale.LocaleIdentifier.swissGerman.rawValue])
  }

  func testFindDisplaysWithFallback_EmptyInputReturnsEmpty() {
    let displays = [MockDisplay]()

    let result = displays.findDisplaysWithFallback(preferredLanguageCodes: [UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue)])

    XCTAssertTrue(result.isEmpty)
  }
}

// MARK: - MockDisplay

fileprivate struct MockDisplay: DisplayLocalizable {
  var locale: UserLocale?
}
