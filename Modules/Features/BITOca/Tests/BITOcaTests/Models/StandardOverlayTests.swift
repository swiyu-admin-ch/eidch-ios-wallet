// swiftlint: disable force_try force_unwrapping
import XCTest
@testable import BITOca

final class StandardOverlayTests: XCTestCase {

  // MARK: Internal

  func testDecode_dataURLStart_returnsOverlayWithDataURL() throws {
    for urn in Self.validDataURLURNs {
      let jsonData = createJson(for: [Self.attributeMock: urn])

      guard let overlay = try? JSONDecoder().decode(StandardOverlay1x0.self, from: jsonData) else {
        return XCTFail("Failed to decode: \(String(data: jsonData, encoding: .utf8)!)")
      }

      XCTAssertEqual(overlay.attributeStandards.count, 1)
      XCTAssertEqual(overlay.attributeStandards[Self.attributeMock], .dataURLScheme)
    }
  }

  func testDecode_unknownURN_returnsOverlayWithUnknown() throws {
    let unknownURN = "urn:ietf:rfc:XXXX"
    let jsonData = createJson(for: [Self.attributeMock: unknownURN])

    guard let overlay = try? JSONDecoder().decode(StandardOverlay1x0.self, from: jsonData) else {
      return XCTFail("Failed to decode: \(String(data: jsonData, encoding: .utf8)!)")
    }

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

  private func createJson(for attributes: [String: String]) -> Data {
    let attributesData = try! JSONSerialization.data(withJSONObject: attributes)
    let attributesString = String(data: attributesData, encoding: .utf8)!
    return "{\"capture_base\": \"captureBase\",\"type\": \"spec/overlays/standard/1.0\", \"attr_standards\": \(attributesString)}".data(using: .utf8)!
  }
}

// swiftlint:enable all
