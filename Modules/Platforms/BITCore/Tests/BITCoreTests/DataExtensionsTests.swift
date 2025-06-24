// swiftlint:disable force_unwrapping
import Foundation
import XCTest
@testable import BITCore

final class DataExtensionsTests: XCTestCase {

  func testCompression_stringCompressionAndDecompression_returnsSameString() throws {
    let string = "some random string to compress with ä, è, \u{1234} or even 👍"
    let data = string.data(using: .utf8)!

    let resultData = try data.compressed().decompressed(ignoreHeaderBytes: false)

    XCTAssertEqual(string, String(data: resultData, encoding: .utf8))
  }
}

// swiftlint:enable all
