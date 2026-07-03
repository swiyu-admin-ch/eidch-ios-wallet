// swiftlint:disable force_unwrapping
import Factory
import Foundation
import Testing
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITCredentialShared

struct CredentialClaimTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    Container.shared.preferredUserLocales.register { ["en-CH"] }
    Container.shared.userTimeZone.register { .gmt }
  }

  // MARK: Internal

  @Test
  func localizedValue_localizedDisplayValue_returnsLocalizedValue() {
    let display = CredentialClaimDisplay(locale: "en", name: "key", value: "someText")
    let claim = Self.createClaim(valueType: .string, value: "", displays: [display])

    #expect(claim.localizedValue == "someText")
  }

  @Test
  func localizedValue_stringValue_returnsValue() {
    let claim = Self.createClaim(valueType: .string, value: "someText")

    #expect(claim.localizedValue == "someText")
  }

  @Test
  func localizedValue_nilValue_returnsDash() {
    let claims = [
      Self.createClaim(valueType: .boolean, value: nil),
      Self.createClaim(valueType: .dateTime, value: nil),
      Self.createClaim(valueType: .imagePng, value: nil),
      Self.createClaim(valueType: .imageJpg, value: nil),
      Self.createClaim(valueType: .string, value: nil),
    ]

    for claim in claims {
      #expect(claim.localizedValue == "–", "for claim \(claim)")
    }
  }

  @Test
  func localizedValue_longerThanMaxLength_truncates() {
    let claim = Self.createClaim(
      valueType: .string,
      value: String(repeating: "a", count: 1802))

    let expectedLength = 1801 // 1800 + "…"
    #expect(claim.localizedValue.count == expectedLength)
  }

  @Test(arguments: [
    (DateFormat.year, "2025"),
    (DateFormat.yearMonth, "January 2025"),
    (DateFormat.date, "01.01.2025"),
    (DateFormat.dateTimeTimeZone, "01.01.2025, 00:00"),
  ])
  func localizedValue_dateTime_formats(format: DateFormat, expected: String) {
    let normalizedDate = "2025-01-01T00:00:00Z"

    let claim = Self.createClaim(
      valueType: .dateTime,
      value: normalizedDate,
      valueDisplayInfo: format.rawValue)

    #expect(claim.localizedValue == expected)
  }

  @Test
  func localizedValue_dateTimeWithDateTimeTimeZoneSecondsFormat_returnsWithTimeZoneOffset() {
    Container.shared.userTimeZone.register { TimeZone(secondsFromGMT: 60 * 60)! }

    let claim = Self.createClaim(
      valueType: .dateTime,
      value: "2025-06-05T08:15:00Z",
      valueDisplayInfo: DateFormat.dateTimeTimeZoneSeconds.rawValue)

    #expect(claim.localizedValue == "05.06.2025, 09:15:00")
  }

  @Test
  func localizedValue_dateTimeWithInvalidDate_returnsOriginal() {
    let claim = Self.createClaim(
      valueType: .dateTime,
      value: "invalid",
      valueDisplayInfo: DateFormat.yearMonth.rawValue)

    #expect(claim.localizedValue == "invalid")
  }

  @Test(arguments: [
    ("de-CH", "1", "1"),
    ("de-CH", "123456", "123’456"),
    ("de-CH", "-1234567", "-1’234’567"),
  ])
  func localizedValue_numericValueWithInteger_returnsLocalized(language: String, input: String, expected: String) {
    assertNumericlocalizedValue(language, input: input, expected: expected)
  }

  @Test(arguments: [
    ("de-CH", "123456.7", "123’456.7"),
    ("de-CH", "-123456.7", "-123’456.7"),
    ("de-CH", "123456.789", "123’456.789"),
    ("de-CH", "-123456.789", "-123’456.789"),
  ])
  func localizedValue_numericValueWithFixedPrecision_returnsLocalized(language: String, input: String, expected: String) {
    assertNumericlocalizedValue(language, input: input, expected: expected)
  }

  @Test(arguments: [
    ("de-CH", "1.23456E3", "1.23456E3"),
    ("de-CH", "-1.23456E+3", "-1.23456E3"),
    ("de-CH", "-1.23456E-3", "-1.23456E-3"),
    ("de-CH", "-1234.567E-3", "-1234.567E-3"),
  ])
  func localizedValue_numericValueWithScientificNotation_returnsLocalized(language: String, input: String, expected: String) {
    assertNumericlocalizedValue(language, input: input, expected: expected)
    assertNumericlocalizedValue(language, input: input.lowercased(), expected: expected.lowercased())
  }

  @Test
  func localizedValue_numericValueWithCurrency_returnsRaw() {
    assertNumericlocalizedValue("de-CH", input: "1.80€", expected: "1.80€")
  }

  @Test(arguments: [
    ("de-CH", "1234E", "1234E"),
    ("de-CH", "1234E-", "1234E-"),
    ("de-CH", "1234-3", "1234-3"),
    ("de-CH", "invalid", "invalid"),
  ])
  func localizedValue_invalid_returnsRaw(language: String, input: String, expected: String) {
    assertNumericlocalizedValue(language, input: input, expected: expected)
  }

  // MARK: Private

  private static let mockValue = "value"

  private static func createClaim(path: ClaimsPathPointer = [.string("key")], valueType: ValueType = .string, value: String? = mockValue, valueDisplayInfo: String? = nil, isSensitive: Bool = false, displays: [CredentialClaimDisplay] = []) -> CredentialClaim {
    CredentialClaim(path: path, value: value, valueType: valueType.rawValue, valueDisplayInfo: valueDisplayInfo, isSensitive: isSensitive, displays: displays)
  }

  private func assertNumericlocalizedValue(_ language: String, input: String, expected: String) {
    Container.shared.preferredUserLocales.register { [language] }
    let claim = Self.createClaim(valueType: ValueType.numeric, value: input)

    #expect(claim.localizedValue == expected, "for \(language) - \(input)")
  }
}
