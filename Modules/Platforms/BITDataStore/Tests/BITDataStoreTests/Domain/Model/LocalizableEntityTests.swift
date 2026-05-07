import RealmSwift
import XCTest
@testable import BITCore

// MARK: - LocalizableEntityTests

final class LocalizableEntityTests: XCTestCase {

  // MARK: Internal

  /// Search a display available in the preferred languages
  func testFindDisplayWithFallback_WhenDisplayAvailableInPreferredLanguage() {
    let displays = createList([
      createDisplay(UserLocale.LocaleIdentifier.swissGerman),
      createDisplay(UserLocale.LocaleIdentifier.swissItalian),
      createDisplay(UserLocale.LocaleIdentifier.swissFrench),
    ])

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
    let displays = createList([
      createDisplay(UserLocale.LocaleIdentifier.swissFrench),
      createDisplay(UserLocale.LocaleIdentifier.swissItalian),
    ])

    let preferredLanguageCodes = [UserLanguageCode]()

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNotNil(display)
    XCTAssertEqual(UserLocale.LocaleIdentifier.swissFrench.rawValue, display?.locale)
  }

  func testFindDisplayWithFallback_WhenDisplaysAreEmpty_ReturnsNil() {
    let displays = createList([])
    let preferredLanguageCodes: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.italian.rawValue),
    ]

    let display = displays.findDisplayWithFallback(preferredLanguageCodes: preferredLanguageCodes)

    XCTAssertNil(display)
  }

  func testFindDisplayWithFallback_WhenDisplayIsSentAsLanguageIdentifier() {
    let displays = createList([
      createDisplay(UserLocale.LanguageIdentifier.italian),
      createDisplay(UserLocale.LanguageIdentifier.german),
      createDisplay(UserLocale.LanguageIdentifier.french),
    ])

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
    let displays = createList([
      createDisplay(UserLocale.LocaleIdentifier.swissGerman),
      createDisplay(UserLocale.LocaleIdentifier.swissFrench),
      createDisplay(UserLocale.LocaleIdentifier.swissItalian),
    ])
    let preferred: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.german.rawValue),
    ]

    let result = displays.findDisplaysWithFallback(preferredLanguageCodes: preferred)

    XCTAssertEqual(result.map(\.locale), [UserLocale.LocaleIdentifier.swissFrench.rawValue])
  }

  func testFindDisplaysWithFallback_WhenNoMatches_ReturnsAllMatchingLocaleOfFirst() {
    let displays = createList([
      createDisplay(UserLocale.LocaleIdentifier.swissGerman),
      createDisplay(UserLocale.LocaleIdentifier.swissItalian),
      createDisplay(UserLocale.LocaleIdentifier.swissGerman),
    ])
    let preferred: [UserLanguageCode] = [
      UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue),
    ]

    let result = displays.findDisplaysWithFallback(preferredLanguageCodes: preferred)

    XCTAssertEqual(result.map(\.locale), [UserLocale.LocaleIdentifier.swissGerman.rawValue, UserLocale.LocaleIdentifier.swissGerman.rawValue])
  }

  func testFindDisplaysWithFallback_EmptyInputReturnsEmpty() {
    let displays = createList([])

    let result = displays.findDisplaysWithFallback(preferredLanguageCodes: [UserLanguageCode(UserLanguageCode.LanguageIdentifier.french.rawValue)])

    XCTAssertTrue(result.isEmpty)
  }

  // MARK: Private

  private func createList(_ elements: [MockDisplay]) -> List<MockDisplay> {
    let list = List<MockDisplay>()
    list.append(objectsIn: elements)
    return list
  }

  private func createDisplay(_ locale: UserLocale.LocaleIdentifier) -> MockDisplay {
    let display = MockDisplay()
    display.locale = locale.rawValue
    return display
  }

  private func createDisplay(_ language: UserLocale.LanguageIdentifier) -> MockDisplay {
    let display = MockDisplay()
    display.locale = language.rawValue
    return display
  }
}

// MARK: - MockDisplay

class MockDisplay: Object, DisplayLocalizable {

  @Persisted var locale: UserLocale?
}
