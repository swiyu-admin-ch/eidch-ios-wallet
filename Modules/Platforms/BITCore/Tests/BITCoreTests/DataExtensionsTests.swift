// swiftlint:disable force_unwrapping
import Foundation
import XCTest
@testable import BITCore

final class DataExtensionsTests: XCTestCase {

  // MARK: Internal

  func testCompression_stringCompressionAndDecompression_returnsSameString() throws {
    let string = "some random string to compress with ä, è, \u{1234} or even 👍"
    let data = string.data(using: .utf8)!

    let resultData = try data.compressed().decompressed(ignoreHeaderBytes: false)

    XCTAssertEqual(string, String(data: resultData, encoding: .utf8))
  }

  func testCompression_stringCompressionAndDecompressionWithLimit_returnsSameString() throws {
    let string = "some random string to compress with ä, è, \u{1234} or even 👍"
    let data = string.data(using: .utf8)!

    let resultData = try data.compressed().decompressedWithLimit(data.count, ignoreHeaderBytes: false)

    XCTAssertEqual(string, String(data: resultData, encoding: .utf8))
  }

  func testDecompressed_insideLimitSmallerThanPageSize_returnsData() throws {
    let limit = Self.PAGE_SIZE - 1
    let (data, compressedData) = try Self.randomCompressedData(count: limit - 1)

    let resultData = try compressedData.decompressedWithLimit(limit, ignoreHeaderBytes: false, pageSize: Self.PAGE_SIZE)

    XCTAssertEqual(data, resultData)
  }

  func testDecompressed_sizeEqualsLimitEqualsPageSize_returnsData() throws {
    let limit = Self.PAGE_SIZE
    let (data, compressedData) = try Self.randomCompressedData(count: limit)

    let resultData = try compressedData.decompressedWithLimit(limit, ignoreHeaderBytes: false, pageSize: Self.PAGE_SIZE)

    XCTAssertEqual(data, resultData)
  }

  func testDecompressed_invalidSizeSmallerPageSize_throwsError() throws {
    let limit = Self.PAGE_SIZE - 1
    let (_, compressedData) = try Self.randomCompressedData(count: limit + 1)

    XCTAssertThrowsError(try compressedData.decompressedWithLimit(limit, ignoreHeaderBytes: false, pageSize: Self.PAGE_SIZE)) { error in
      XCTAssertEqual(error as? DecompressionError, .limitReached)
    }
  }

  func testDecompressed_invalidLimitEqualsPageSize_throwsError() throws {
    let limit = Self.PAGE_SIZE
    let (_, compressedData) = try Self.randomCompressedData(count: limit + 1)

    XCTAssertThrowsError(try compressedData.decompressedWithLimit(limit, ignoreHeaderBytes: false, pageSize: Self.PAGE_SIZE)) { error in
      XCTAssertEqual(error as? DecompressionError, .limitReached)
    }
  }

  func testDecompressed_validSize_returnsData() throws {
    let limit = 10 * 1024
    let (data, compressedData) = try Self.randomCompressedData(count: 9 * 1024)

    let resultData = try compressedData.decompressedWithLimit(limit, ignoreHeaderBytes: false)

    XCTAssertEqual(data, resultData)
  }

  func testDecompressed_invalidSize_throwsError() throws {
    let limit = 10 * 1024
    let (_, compressedData) = try Self.randomCompressedData(count: limit + 1)

    XCTAssertThrowsError(try compressedData.decompressedWithLimit(limit, ignoreHeaderBytes: false)) { error in
      XCTAssertEqual(error as? DecompressionError, .limitReached)
    }
  }

  // MARK: Private

  private static let PAGE_SIZE = 10

  private static func randomCompressedData(count: Int) throws -> (Data, Data) {
    let bytes = [UInt32](repeating: 0, count: count).map { _ in arc4random() }
    let data = Data(bytes: bytes, count: count)
    return try (data, data.compressed())
  }

}
