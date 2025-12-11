import BITCore
import BITCredentialShared
import BITEntities
import Factory
import XCTest
@testable import BITCredential

final class CredentialClaimViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissEnglish.rawValue] }
    Container.shared.userTimeZone.register { .gmt }
  }

  func testImageData_returnsImageDataForSupportedValueType() {
    let claims = [
      Self.createClaim(valueType: ValueType.boolean, value: "true"),
      Self.createClaim(valueType: ValueType.dateTime, value: "2025-06-05T00:00:00Z"),
      Self.createClaim(valueType: ValueType.imagePng, value: "iVBORw0K"),
      Self.createClaim(valueType: ValueType.imageJpg, value: "iVBORw0K"),
      Self.createClaim(valueType: ValueType.string, value: "string"),
    ]

    for claim in claims {
      let vm = CredentialClaimViewModel(claim)

      if ValueType.supportedImageTypes.contains(ValueType(rawValue: claim.valueType) ?? .string) {
        XCTAssertNotNil(vm.imageData)
      } else {
        XCTAssertNil(vm.imageData)
      }
    }
  }

  func testImageData_nilClaim_returnsNil() {
    let claim = Self.createClaim(valueType: ValueType.imagePng, value: nil)

    let vm = CredentialClaimViewModel(claim)

    XCTAssertNil(vm.imageData)
  }

  func testNameLabel_withDisplay_returnsDisplayName() {
    let display = CredentialClaimDisplay(locale: "en", name: "forename")
    let claim = Self.createClaim(valueType: ValueType.string, displays: [display])

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.nameLabel, "forename")
  }

  func testNameLabel_withoutDisplay_returnsKey() {
    let claim = Self.createClaim(key: "username", valueType: ValueType.string, displays: [])

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.nameLabel, "username")
  }

  func testValueLabel_localizedDisplayValue_returnsLocalizedValue() {
    let display = CredentialClaimDisplay(locale: "en", name: "key", value: "someText")
    let claim = Self.createClaim(valueType: ValueType.string, value: "", displays: [display])
    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.valueLabel, "someText")
  }

  func testValueLabel_stringValue_returnsValue() {
    let claim = Self.createClaim(valueType: ValueType.string, value: "someText")

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.valueLabel, "someText")
  }

  func testValueLabel_nilValue_returnsHiphen() {
    let claims = [
      Self.createClaim(valueType: ValueType.boolean, value: nil),
      Self.createClaim(valueType: ValueType.dateTime, value: nil),
      Self.createClaim(valueType: ValueType.imagePng, value: nil),
      Self.createClaim(valueType: ValueType.imageJpg, value: nil),
      Self.createClaim(valueType: ValueType.string, value: nil),
    ]

    for claim in claims {
      let vm = CredentialClaimViewModel(claim)

      XCTAssertEqual(vm.valueLabel, "-", "for claim \(claim)")
    }
  }

  func testValueLabel_longerThanMaxLength_truncates() {
    let claim = Self.createClaim(valueType: ValueType.string, value: String(repeating: "a", count: 1802))

    let vm = CredentialClaimViewModel(claim)

    let expectedLength = 1801 // 1800 + "…"
    XCTAssertEqual(vm.valueLabel.count, expectedLength)
  }

  func testValueLabel_dateTime_formats() {
    let normalizedDate = "2025-01-01T00:00:00Z"
    let testCases: [DateParserResult.Format: String] = [
      .year: "2025",
      .yearMonth: "January 2025",
      .date: "01.01.2025",
      .dateTimeTimeZone: "01.01.2025, 00:00",
    ]

    for (format, expected) in testCases {
      let claim = Self.createClaim(valueType: ValueType.dateTime, value: normalizedDate, valueDisplayInfo: format.rawValue)

      let vm = CredentialClaimViewModel(claim)

      XCTAssertEqual(vm.valueLabel, expected, "for format \(format)")
    }
  }

  func testValueLabel_dateTimeWithDateTimeTimeZoneSecondsFormat_returnsWithTimeZoneOffset() {
    // swiftlint: disable force_unwrapping
    Container.shared.userTimeZone.register { TimeZone(secondsFromGMT: 60 * 60)! }
    // swiftlint: enable force_unwrapping
    let claim = Self.createClaim(valueType: ValueType.dateTime, value: "2025-06-05T08:15:00Z", valueDisplayInfo: DateParserResult.Format.dateTimeTimeZoneSeconds.rawValue)

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.valueLabel, "05.06.2025, 09:15:00")
  }

  func testValueLabel_dateTimeWithInvalidDate_returnsOriginal() {
    let claim = Self.createClaim(valueType: ValueType.dateTime, value: "invalid", valueDisplayInfo: DateParserResult.Format.yearMonth.rawValue)

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.valueLabel, "invalid")
  }

  func testValueLabel_numericValue_formatsLocalizedSeparators() {
    let expectedForLanguage = [
      (language: "de-CH", input: "123456.7", expected: "123’456.7"),
      (language: "fr-CH", input: "123456.7", expected: "123’456.7"),
      (language: "it-CH", input: "123456.7", expected: "123’456.7"),
      (language: "rm-CH", input: "123456.7", expected: "123’456.7"),
      (language: "en-US", input: "123456.7", expected: "123,456.7"),
      (language: "de-DE", input: "123456.7", expected: "123.456,7"),
    ]

    for (language, input, expected) in expectedForLanguage {
      assertNumericValueLabel(language, input: input, expected: expected)
    }
  }

  func testValueLabel_numericValueWithInteger_returnsLocalized() {
    let expectedForLanguage = [
      (language: "de-CH", input: "1", expected: "1"),
      (language: "de-CH", input: "123456", expected: "123’456"),
      (language: "de-CH", input: "-1234567", expected: "-1’234’567"),
    ]

    for (language, input, expected) in expectedForLanguage {
      assertNumericValueLabel(language, input: input, expected: expected)
    }
  }

  func testValueLabel_numericValueWithFixedPrecision_returnsLocalized() {
    let expectedForLanguage = [
      (language: "de-CH", input: "123456.7", expected: "123’456.7"),
      (language: "de-CH", input: "-123456.7", expected: "-123’456.7"),
      (language: "de-CH", input: "123456.789", expected: "123’456.789"),
      (language: "de-CH", input: "-123456.789", expected: "-123’456.789"),
    ]

    for (language, input, expected) in expectedForLanguage {
      assertNumericValueLabel(language, input: input, expected: expected)
    }
  }

  func testValueLabel_numericValueWithScientificNotation_returnsLocalized() {
    let expectedForLanguage = [
      (language: "de-CH", input: "1.23456E3", expected: "1.23456E3"),
      (language: "de-CH", input: "-1.23456E+3", expected: "-1.23456E3"),
      (language: "de-CH", input: "-1.23456E-3", expected: "-1.23456E-3"),
      (language: "de-CH", input: "-1234.567E-3", expected: "-1234.567E-3"),
    ]

    for (language, input, expected) in expectedForLanguage {
      assertNumericValueLabel(language, input: input, expected: expected)
      assertNumericValueLabel(language, input: input.lowercased(), expected: expected.lowercased())
    }
  }

  func testValueLabel_numericValueWithCurrency_returnsRaw() {
    assertNumericValueLabel("de-CH", input: "1.80€", expected: "1.80€")
  }

  func testValueLabel_invalid_returnsRaw() {
    let expectedForLanguage = [
      (language: "de-CH", input: "1234E", expected: "1234E"),
      (language: "de-CH", input: "1234E-", expected: "1234E-"),
      (language: "de-CH", input: "1234-3", expected: "1234-3"),
      (language: "de-CH", input: "invalid", expected: "invalid"),
    ]

    for (language, input, expected) in expectedForLanguage {
      assertNumericValueLabel(language, input: input, expected: expected)
    }
  }

  func testIsSensitive_boolean_returnsBoolean() {
    for isSensitive in [true, false] {
      let claim = Self.createClaim(valueType: ValueType.numeric, isSensitive: isSensitive)

      let vm = CredentialClaimViewModel(claim)

      XCTAssertEqual(isSensitive, vm.isSensitive, "Error for: \(isSensitive)")
    }
  }

  // MARK: Private

  private static let mockValue = "value"

  private static func createClaim(key: String = "key", valueType: ValueType = .string, value: String? = mockValue, valueDisplayInfo: String? = nil, isSensitive: Bool = false, displays: [CredentialClaimDisplay] = []) -> CredentialClaim {
    CredentialClaim(key: key, value: value, valueType: valueType.rawValue, valueDisplayInfo: valueDisplayInfo, isSensitive: isSensitive, displays: displays)
  }

  private func assertNumericValueLabel(_ language: String, input: String, expected: String) {
    let claim = Self.createClaim(valueType: ValueType.numeric, value: input)
    Container.shared.preferredUserLocales.register { [language] }

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.valueLabel, expected, "for \(language) - \(input)")
  }
}
