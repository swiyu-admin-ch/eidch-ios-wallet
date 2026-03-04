import XCTest
@testable import BITJsonCanonicalizer

// MARK: - JsonCanonicalizerTests

final class JsonCanonicalizerTests: XCTestCase {

  // MARK: Internal

  func testCanonicalizer_arrayInput() throws {
    try canonicalize(.arrays)
    try canonicalizeUTF8(.arrays)
  }

  func testCanonicalizer_frenchInput() throws {
    try canonicalize(.french)
    try canonicalizeUTF8(.french)
  }

  func testCanonicalizer_structureInput() throws {
    try canonicalize(.structures)
    try canonicalizeUTF8(.structures)
  }

  func testCanonicalizer_unicodeInput() throws {
    try canonicalize(.unicode)
    try canonicalizeUTF8(.unicode)
  }

  func testCanonicalizer_valuesInput() throws {
    try canonicalize(.values)
    try canonicalizeUTF8(.values)
  }

  func testCanonicalizer_weirdInput() throws {
    try canonicalize(.weird)
    try canonicalizeUTF8(.weird)
  }

  // MARK: Private

  private func canonicalize(_ sample: JsonSample) throws {
    let input = try sample.input()
    let expectedOutput = try sample.output()

    let output = try JsonCanonicalizer().canonicalizeToString(input)

    XCTAssertEqual(expectedOutput, output)
  }

  private func canonicalizeUTF8(_ sample: JsonSample) throws {
    let input = try sample.input()
    let expectedOutput = try String(data: sample.outputHex(), encoding: .utf8)

    let output = try JsonCanonicalizer().canonicalize(jsonString: input)

    XCTAssertEqual(expectedOutput, dataToHexString(output))
  }

  private func dataToHexString(_ data: Data) -> String {
    data.map { String(format: "%02x", $0) }.joined()
  }

}
