import Foundation
import Testing
@testable import BITJsonCanonicalizer

// MARK: - JsonCanonicalizerTests

struct JsonCanonicalizerTests {

  // MARK: Internal

  @Test
  func canonicalizer_arrayInput() throws {
    try canonicalize(.arrays)
    try canonicalizeUTF8(.arrays)
  }

  @Test
  func canonicalizer_frenchInput() throws {
    try canonicalize(.french)
    try canonicalizeUTF8(.french)
  }

  @Test
  func canonicalizer_structureInput() throws {
    try canonicalize(.structures)
    try canonicalizeUTF8(.structures)
  }

  @Test
  func canonicalizer_unicodeInput() throws {
    try canonicalize(.unicode)
    try canonicalizeUTF8(.unicode)
  }

  @Test
  func canonicalizer_valuesInput() throws {
    try canonicalize(.values)
    try canonicalizeUTF8(.values)
  }

  @Test
  func canonicalizer_weirdInput() throws {
    try canonicalize(.weird)
    try canonicalizeUTF8(.weird)
  }

  @Test
  func canonicalizer_precomposedAccentedValue_isPreservedAsNFC() throws {
    let input = "{\"description\":\"Gr\u{00FC}\u{00DF}e\"}" // "Grüße" with a precomposed ü (U+00FC)
    let hex = try dataToHexString(JsonCanonicalizer().canonicalize(jsonString: input))

    #expect(hex.contains("c3bc"), "precomposed ü (U+00FC) must be serialized as-is")
    #expect(!hex.contains("75cc88"), "ü must not be decomposed to u + combining diaeresis U+0308")
  }

  // MARK: Private

  private func canonicalize(_ sample: JsonSample) throws {
    let input = try sample.input()
    let expectedOutput = try sample.output()

    let output = try JsonCanonicalizer().canonicalizeToString(input)

    #expect(expectedOutput == output)
  }

  private func canonicalizeUTF8(_ sample: JsonSample) throws {
    let input = try sample.input()
    let expectedOutput = try String(data: sample.outputHex(), encoding: .utf8)

    let output = try JsonCanonicalizer().canonicalize(jsonString: input)

    #expect(expectedOutput == dataToHexString(output))
  }

  private func dataToHexString(_ data: Data) -> String {
    data.map { String(format: "%02x", $0) }.joined()
  }
}
