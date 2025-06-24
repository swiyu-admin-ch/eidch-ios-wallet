// swiftlint: disable force_try force_unwrapping
import XCTest
@testable import BITOca

final class CharacterEncodingOverlayTests: XCTestCase {

  // MARK: Internal

  func testDecode_utf8_returnsOverlayWithUTF8() throws {
    for encoding in ["UTF-8", "utf-8"] {
      let jsonData = createJson(for: encoding)

      guard let overlay = try? JSONDecoder().decode(CharacterEncodingOverlay1x0.self, from: jsonData) else {
        return XCTFail("Failed to decode: \(String(data: jsonData, encoding: .utf8)!)")
      }

      XCTAssertEqual(overlay.defaultCharacterEncoding, .utf8)
    }
  }

  func testDecode_base64_returnsOverlayWithBase64() throws {
    for encoding in ["Base64", "base64"] {
      let jsonData = createJson(for: encoding)

      guard let overlay = try? JSONDecoder().decode(CharacterEncodingOverlay1x0.self, from: jsonData) else {
        return XCTFail("Failed to decode: \(String(data: jsonData, encoding: .utf8)!)")
      }

      XCTAssertEqual(overlay.defaultCharacterEncoding, .base64)
    }
  }

  func testDecode_unknown_returnsOverlayWithUnknown() throws {
    let unknownEncoding = "unknown"
    let jsonData = createJson(for: unknownEncoding)

    guard let overlay = try? JSONDecoder().decode(CharacterEncodingOverlay1x0.self, from: jsonData) else {
      return XCTFail("Failed to decode: \(String(data: jsonData, encoding: .utf8)!)")
    }

    XCTAssertEqual(overlay.defaultCharacterEncoding, .unknown(rawString: unknownEncoding))
  }

  // MARK: Private

  private func createJson(for encoding: String) -> Data {
    "{\"capture_base\": \"captureBase\",\"type\": \"spec/overlays/character_encoding/1.0\", \"default_character_encoding\": \"\(encoding)\"}".data(using: .utf8)!
  }
}

// swiftlint:enable all
