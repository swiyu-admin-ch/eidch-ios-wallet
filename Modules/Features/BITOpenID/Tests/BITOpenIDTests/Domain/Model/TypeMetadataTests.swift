import XCTest
@testable import BITOpenID

// swiftlint:disable force_unwrapping
final class TypeMetadataTests: XCTestCase {

  // MARK: - Valid JSON Decoding

  func testValidTypeMetadataDecoding() {
    let metadata = TypeMetadata.Mock.sampleUrlOca

    XCTAssertEqual(metadata.vct, "https://example.com/education_credential")
    XCTAssertEqual(metadata.name, "Education Credential")
    XCTAssertEqual(metadata.description, "A credential for academic achievements")
    XCTAssertEqual(metadata.extends, URL(string: "https://example.com/base_credential"))
    XCTAssertEqual(metadata.schema, "credential_schema")
    XCTAssertEqual(metadata.schemaUrl, URL(string: "https://example.com/schema.json"))

    // Display Checks
    XCTAssertEqual(metadata.displays?.count, 1)
    let display = metadata.displays!.first!
    XCTAssertEqual(display.lang, "en")
    XCTAssertEqual(display.name, "Education Credential")
    XCTAssertEqual(display.description, "Academic credential for students")

    // OCA
    XCTAssertEqual(display.rendering?.oca?.uri, "https://example.com/oca/oca-bundle.json")
    XCTAssertEqual(display.rendering?.oca?.uriIntegrity, "sha256-9cLlJNXN-TsMk-PmKjZ5t0WRL5ca_xGgX3c1VLmXfh-WRL5")

    // Rendering Checks
    let rendering = display.rendering!
    XCTAssertNotNil(rendering.simple)
    XCTAssertEqual(rendering.simple?.backgroundColor, "#FFFFFF")
    XCTAssertEqual(rendering.simple?.textColor, "#000000")

    let logo = rendering.simple?.logo
    XCTAssertEqual(logo?.uri, "https://example.com/logo.png")
    XCTAssertEqual(logo?.altText, "University Logo")
    XCTAssertEqual(logo?.uriIntegrity, "sha256-validBase64==")

    // SVG Templates
    XCTAssertEqual(rendering.svgTemplates?.count, 1)
    let svgTemplate = rendering.svgTemplates!.first!
    XCTAssertEqual(svgTemplate.uri, "https://example.com/template.svg")
    XCTAssertEqual(svgTemplate.uriIntegrity, "sha256-validBase64==")
    XCTAssertEqual(svgTemplate.properties?.orientation, "landscape")
    XCTAssertEqual(svgTemplate.properties?.colorScheme, "light")
    XCTAssertEqual(svgTemplate.properties?.contrast, "high")

    // Claims
    XCTAssertEqual(metadata.claims?.count, 2)

    let claim1 = metadata.claims![0]
    XCTAssertEqual(claim1.path.count, 1)
    XCTAssertEqual(claim1.display?.count, 1)
    XCTAssertEqual(claim1.display!.first!.lang, "en")
    XCTAssertEqual(claim1.display!.first!.label, "Full Name")
    XCTAssertEqual(claim1.display!.first!.description, "The student's full name.")
    XCTAssertEqual(claim1.sd, .allowed)
    XCTAssertEqual(claim1.svgId, "full_name")

    let claim2 = metadata.claims![1]
    XCTAssertEqual(claim2.path.count, 3)
    XCTAssertEqual(claim2.sd, .never)
    XCTAssertNil(claim2.display)
  }

  // MARK: - Invalid JSON Handling

  func testInvalidTypeMetadataDecoding() {
    let json = """
    {
        "vct": "https://example.com/education_credential",
        "name": "Education Credential",
        "claims": [
            { "path": 42 } // Invalid path, should be an array
        ]
    }
    """
    let jsonData = json.data(using: .utf8)!

    XCTAssertThrowsError(try JSONDecoder().decode(TypeMetadata.self, from: jsonData)) { error in
      XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(error)")
    }
  }

  // MARK: - Edge Cases

  func testEmptyTypeMetadataDecoding() {
    let json = "{}"
    let jsonData = json.data(using: .utf8)!

    do {
      let metadata = try JSONDecoder().decode(TypeMetadata.self, from: jsonData)
      XCTAssertNil(metadata.vct)
      XCTAssertNil(metadata.name)
      XCTAssertNil(metadata.description)
      XCTAssertNil(metadata.extends)
      XCTAssertNil(metadata.displays)
      XCTAssertNil(metadata.claims)
      XCTAssertNil(metadata.schema)
      XCTAssertNil(metadata.schemaUrl)
    } catch {
      XCTFail("Decoding failed: \(error)")
    }
  }

  func testPartialTypeMetadataDecoding() {
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
    let jsonData = json.data(using: .utf8)!

    do {
      let metadata = try JSONDecoder().decode(TypeMetadata.self, from: jsonData)
      XCTAssertEqual(metadata.vct, "https://example.com/education_credential")
      XCTAssertEqual(metadata.name, "Education Credential")
      XCTAssertEqual(metadata.displays?.count, 1)

      let display = metadata.displays!.first!
      XCTAssertEqual(display.lang, "en")
      XCTAssertEqual(display.name, "Partial Display")
      XCTAssertNil(display.description)
      XCTAssertNil(display.rendering)
    } catch {
      XCTFail("Decoding failed: \(error)")
    }
  }
}

// swiftlint:enable force_unwrapping
