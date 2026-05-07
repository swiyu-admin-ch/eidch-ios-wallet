import XCTest
@testable import BITOca

final class EntryCodeOverlayTests: XCTestCase {

  // MARK: Internal

  func testInit_withKeySetAndSAID_ignoresSAID() throws {
    let overlay: EntryCodeOverlay1x0 = try JSONDecoder().decode(EntryCodeOverlay1x0.self, from: createJson())
    XCTAssertEqual(overlay.attributeEntryCodes.keys.count, 1)
    XCTAssertNil(overlay.attributeEntryCodes["lastName"])
    XCTAssertEqual(overlay.attributeEntryCodes["isOver18"], ["true", "false"])
  }

  // MARK: Private

  // swiftlint: disable  force_unwrapping

  private func createJson() -> Data {
    """
    {
      "type": "spec/overlays/entry_code/1.0",
      "capture_base": "ICsJn_lrL5c1T7pDCEvvrHje0-3uZv9-IQ9Ky2inX-nV",
      "attribute_entry_codes": {
        "lastName": "SAID",
        "isOver18": ["true", "false"]
      }
    }
    """
    .data(using: .utf8)!
  }
}

// swiftlint:enable all
