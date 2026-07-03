import XCTest
@testable import BITOpenID

// swiftlint:disable force_unwrapping
final class TypeMetadataTests: XCTestCase {

  // MARK: - Valid JSON Decoding

  func testValidTypeMetadataDecoding() throws {
    let metadata = TypeMetadata.Mock.sample

    XCTAssertEqual(metadata.vct, "https://example.com/education_credential")
    XCTAssertEqual(metadata.name, "Education Credential")
    XCTAssertEqual(metadata.description, "A credential for academic achievements")
    XCTAssertEqual(metadata.schemaUrl, URL(string: "https://example.com/schema.json"))
    XCTAssertEqual(metadata.schemaIntegrity, "sha256-o984vn819a48ui1llkwPmKjZ5t0WRL5ca_xGgX3c1VLmXfh")

    // Display Checks
    XCTAssertEqual(metadata.displays?.count, 1)
    let display = try XCTUnwrap(metadata.displays?.first)
    XCTAssertEqual(display.lang, "en")
    XCTAssertEqual(display.name, "Education Credential")
    XCTAssertEqual(display.description, "Academic credential for students")

    // OCA
    XCTAssertEqual(display.rendering?.oca?.uri, "https://example.com/oca/oca-bundle.json")
    XCTAssertEqual(display.rendering?.oca?.uriIntegrity, "sha256-9cLlJNXN-TsMk-PmKjZ5t0WRL5ca_xGgX3c1VLmXfh-WRL5")
  }

  func testInvalidTypeMetadataDecoding() throws {
    let json = """
    {
        "vct": "https://example.com/education_credential",
        "name": "Education Credential",
        "claims": [
            { "path": 42 } // Invalid path, should be an array
        ]
    }
    """
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    XCTAssertThrowsError(try JSONDecoder().decode(TypeMetadata.self, from: jsonData)) { error in
      XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(error)")
    }
  }

  func testPartialTypeMetadataDecoding() throws {
    let json = """
    {
        "vct": "https://example.com/education_credential",
        "name": "Education Credential",
        "display": [
            {
                "lang": "en",
                "name": "Partial Display"
            }
        ]
    }
    """
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    do {
      let metadata = try JSONDecoder().decode(TypeMetadata.self, from: jsonData)
      XCTAssertEqual(metadata.vct, "https://example.com/education_credential")
      XCTAssertEqual(metadata.name, "Education Credential")
      XCTAssertEqual(metadata.displays?.count, 1)

      let display = try XCTUnwrap(metadata.displays?.first)
      XCTAssertEqual(display.lang, "en")
      XCTAssertEqual(display.name, "Partial Display")
      XCTAssertNil(display.description)
      XCTAssertNil(display.rendering)
    } catch {
      XCTFail("Decoding failed: \(error)")
    }
  }
}
