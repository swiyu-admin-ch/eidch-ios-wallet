// swiftlint: disable force_try force_unwrapping
import XCTest
@testable import BITOca

final class StandardOverlayTests: XCTestCase {

  // MARK: Internal

  func testDecode_dataURLStart_returnsOverlayWithDataURL() {
    for urn in Self.validDataURLURNs {
      let overlay = createOverlay(for: [Self.attributeMock: urn])

      XCTAssertEqual(overlay.attributeStandards.count, 1)
      XCTAssertEqual(overlay.attributeStandards[Self.attributeMock], .dataURLScheme)
    }
  }

  func testDecode_Iso8601Start_returnsOverlayWithdateTimeIso8601() {
    for urn in Self.validDateTimeIso8601URNs {
      let overlay = createOverlay(for: [Self.attributeMock: urn])

      XCTAssertEqual(overlay.attributeStandards.count, 1)
      XCTAssertEqual(overlay.attributeStandards[Self.attributeMock], .dateTimeIso8601)
    }
  }

  func testDecode_unixEpochStart_returnsOverlayWithdateTimeUnixEpoch() {
    for urn in Self.validDateTimeUnixEpochURNs {
      let overlay = createOverlay(for: [Self.attributeMock: urn])

      XCTAssertEqual(overlay.attributeStandards.count, 1)
      XCTAssertEqual(overlay.attributeStandards[Self.attributeMock], .dateTimeUnixEpoch)
    }
  }

  func testDecode_unknownURN_returnsOverlayWithUnknown() {
    let unknownURN = "urn:ietf:rfc:XXXX"
    let overlay = createOverlay(for: [Self.attributeMock: unknownURN])

    XCTAssertEqual(overlay.attributeStandards.count, 1)
    XCTAssertEqual(overlay.attributeStandards[Self.attributeMock], .unknown(rawString: unknownURN))
  }

  // MARK: Private

  private static let attributeMock = "attribute"
  private static let validDataURLURNs = [
    "urn:ietf:rfc:2397",
    "urn:ietf:rfc:2397:test",
    "urn:ietf:rfc:2397#test",
    "urn:ietf:rfc:2397?=test",
    "urn:ietf:rfc:2397?+test",
    "urn:ietf:rfc:2397?+test?=test#test",
  ]
  private static let validDateTimeIso8601URNs = [
    "urn:iso:std:iso:8601",
    "urn:iso:std:iso:8601:-1:en",
    "urn:iso:std:iso:8601?+test?=test#test",
  ]
  private static let validDateTimeUnixEpochURNs = [
    "urn:iso:std:iso-iec:9945",
    "urn:iso:std:iso-iec-ieee:9945",
    "urn:iso:std:iso-iec:9945:-1:en",
    "urn:iso:std:iso-iec-ieee:9945:-1:en",
    "urn:iso:std:iso-iec:9945?+test?=test#test",
    "urn:iso:std:iso-iec-ieee:9945?+test?=test#test",
  ]

  private func createOverlay(for attributes: [String: String]) -> StandardOverlay1x0 {
    let attributesData = try! JSONSerialization.data(withJSONObject: attributes)
    let attributesString = String(data: attributesData, encoding: .utf8)!
    let jsonData = "{\"capture_base\": \"captureBase\",\"type\": \"spec/overlays/standard/1.0\", \"attr_standards\": \(attributesString)}".data(using: .utf8)!

    return try! JSONDecoder().decode(StandardOverlay1x0.self, from: jsonData)
  }
}

// swiftlint:enable all
