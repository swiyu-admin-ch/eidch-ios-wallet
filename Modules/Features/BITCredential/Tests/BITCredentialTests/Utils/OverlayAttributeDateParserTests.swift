import XCTest
@testable import BITCore
@testable import BITCredential
@testable import BITOca

final class OverlayAttributeDateParserTests: XCTestCase {

  // MARK: Internal

  func testParse_attributeWithIso8601DateTimeVariations_returnsNormalizedDateWithFormat() {
    let attribute = Self.createOverlayBundleAttribute(standard: .dateTimeIso8601)

    let dateTimes = [
      "2025-06-05T23:59:59.999+00:00",
      "2025-06-05T23:59:59.99+00:00",
      "2025-06-05T23:59:59.9+00:00",
      "2025-06-05T23:59:59.999Z",
      "2025-06-05T23:59:59.99Z",
      "2025-06-05T23:59:59.9Z",
      "2025-06-05T23:59:59.999",
      "2025-06-05T23:59:59.99",
      "2025-06-05T23:59:59.9",
      "2025-06-05T23:59:59+00:00",
      "2025-06-05T23:59:59Z",
      "2025-06-05T23:59:59",
    ]

    for input in dateTimes {
      let result = parser.parse(input, with: attribute)

      XCTAssertEqual(result?.normalizedDate, "2025-06-05T23:59:59Z", "for input \(input) and normalized: \(String(describing: result?.normalizedDate))")
    }
  }

  func testParse_attributeWithIso8601StandardAndOffset_returnsNormalizedDate() {
    let attribute = Self.createOverlayBundleAttribute(standard: .dateTimeIso8601)

    let result = parser.parse("2025-06-05T23:59:59.99+02:00", with: attribute)

    XCTAssertEqual(result?.normalizedDate, "2025-06-05T21:59:59Z")
    XCTAssertEqual(result?.format, .dateTimeTimeZoneSecondsFractional)
  }

  func testParse_attributeWithIso8601StandardDateOnly_parsesFormat() {
    let testCases: [(raw: String, format: DateFormat, expectedNormalizedDate: String)] = [
      ("2025-06-05", .date, "2025-06-05T00:00:00Z"),
      ("2025-06", .yearMonth, "2025-06-01T00:00:00Z"),
      ("2025", .year, "2025-01-01T00:00:00Z"),
    ]
    let attribute = Self.createOverlayBundleAttribute(standard: .dateTimeIso8601)

    for (raw, format, expectedNormalizedDate) in testCases {
      let result = parser.parse(raw, with: attribute)

      XCTAssertEqual(result?.normalizedDate, expectedNormalizedDate, "for raw: \(raw)")
      XCTAssertEqual(result?.format, format, "for raw: \(raw)")
    }
  }

  func testParse_attributeWithIso8601StandardTimeOnly_parsesFormat() {
    let testCases: [(raw: String, format: DateFormat, expectedNormalizedDate: String)] = [
      ("23:59:59.999Z", .timeTimeZoneSecondsFractional, "2000-01-01T23:59:59Z"),
      ("23:59:59Z", .timeTimeZoneSeconds, "2000-01-01T23:59:59Z"),
      ("23:59Z", .timeTimeZone, "2000-01-01T23:59:00Z"),
      ("23:59:59.999", .timeSecondsFractional, "2000-01-01T23:59:59Z"),
      ("23:59:59", .timeSeconds, "2000-01-01T23:59:59Z"),
      ("23:59", .time, "2000-01-01T23:59:00Z"),
    ]
    let attribute = Self.createOverlayBundleAttribute(standard: .dateTimeIso8601)

    for (raw, format, expectedNormalizedDate) in testCases {
      let result = parser.parse(raw, with: attribute)

      XCTAssertEqual(result?.normalizedDate, expectedNormalizedDate, "for raw: \(raw)")
      XCTAssertEqual(result?.format, format, "for raw: \(raw)")
    }
  }

  func testParse_attributeWithUnixEpochStandard_parsesEpochAndFormat() {
    let attribute = Self.createOverlayBundleAttribute(standard: .dateTimeUnixEpoch)

    let result = parser.parse("1749167999", with: attribute)
    XCTAssertEqual(result?.normalizedDate, "2025-06-05T23:59:59Z")
    XCTAssertEqual(result?.format, .dateTimeTimeZoneSeconds)
  }

  func testParse_Iso8601ClaimWithoutIso8601Standard_parsesIso8601() {
    let attribute = Self.createOverlayBundleAttribute(standard: nil)
    let result = parser.parse("2025-01-01", with: attribute)
    XCTAssertEqual(result?.normalizedDate, "2025-01-01T00:00:00Z")
  }

  func testParse_UnixWithoutUnixStandard_returnsNil() {
    let attribute = Self.createOverlayBundleAttribute(standard: nil)
    XCTAssertNil(parser.parse("1464739200", with: attribute))
  }

  func testParse_invalidDateString_returnsInputString() {
    let dateTimeIso8601Attribute = Self.createOverlayBundleAttribute(standard: .dateTimeIso8601)
    let unixEpochAttribute = Self.createOverlayBundleAttribute(standard: .dateTimeUnixEpoch)
    let invalids = [
      "",
      "not-a-date",
      "2016-13-01",
      "2016-00-10T00:00",
    ]

    for invalid in invalids {
      XCTAssertNil(parser.parse(invalid, with: dateTimeIso8601Attribute))
      XCTAssertNil(parser.parse(invalid, with: unixEpochAttribute))
    }
  }

  // MARK: Private

  private let parser = OverlayAttributeDateParser()

  private static func createOverlayBundleAttribute(standard: Standard?) -> OverlayBundleAttribute {
    OverlayBundleAttribute(captureBaseDigest: "digest", name: "name", attributeType: .dateTime, standard: standard)
  }
}
