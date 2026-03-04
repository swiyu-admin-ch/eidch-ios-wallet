import Foundation
import Spyable
import XCTest
@testable import BITOpenID

// MARK: - TokenStatusListByteDecoderTests

final class TokenStatusListByteDecoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    decoder = TokenStatusListByteDecoder()
  }

  func testTokenStatusListWith3BytesAnd2Bits() throws {
    var value = try decoder.decode(Data(fromArray: BYTES), bits: 2, index: 0)
    XCTAssertEqual(value, 1)

    value = try decoder.decode(Data(fromArray: BYTES), bits: 2, index: 1)
    XCTAssertEqual(value, 2)

    value = try decoder.decode(Data(fromArray: BYTES), bits: 2, index: 6)
    XCTAssertEqual(value, 0)

    value = try decoder.decode(Data(fromArray: BYTES), bits: 2, index: 10)
    XCTAssertEqual(value, 3)
  }

  func testTokenStatusListWith1ByteAnd1Bits() throws {
    let startIndex = BIT_STRING_SHORT.startIndex
    for index in BIT_STRING_SHORT.indices {
      let value = try decoder.decode(Data(fromArray: BYTES_SHORT), bits: 1, index: BIT_STRING_SHORT.distance(from: startIndex, to: index))
      let expected = String(BIT_STRING_SHORT.reversed())[index].wholeNumberValue
      XCTAssertEqual(value, expected)
    }
  }

  func testTokenStatusListWith1ByteAnd4Bits() throws {
    var value = try decoder.decode(Data(fromArray: BYTES_SHORT), bits: 4, index: 0)
    XCTAssertEqual(value, 9)

    value = try decoder.decode(Data(fromArray: BYTES_SHORT), bits: 4, index: 1)
    XCTAssertEqual(value, 12)
  }

  func testTokenStatusListWith1ByteAnd8Bits() throws {
    let value = try decoder.decode(Data(fromArray: BYTES_SHORT), bits: 8, index: 0)
    XCTAssertEqual(value, 201)
  }

  func testTokenStatusListWithIndexOutOfBounds() throws {
    XCTAssertThrowsError(try decoder.decode(Data(fromArray: BYTES_SHORT), bits: 2, index: 1000)) { error in
      XCTAssertEqual(error as? TokenStatusListByteDecoder.DecoderError, .indexOutOfBounds)
    }
  }

  // MARK: Private

  // swiftlint: disable all
  // Create a token status list like in 9.1 of https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-02.html#name-further-examples
  private let BYTES = [0xC9, 0x44, 0xF9] as [UInt8] // "110010010100010011111001"
  private let BYTES_SHORT = [0xC9] as [UInt8] // "11001001"
  private let BIT_STRING_SHORT = "11001001"
  private var decoder: TokenStatusListByteDecoder!

  // swiftlint: enable all
}

extension Data {
  fileprivate init(fromArray values: [some Any]) {
    self = values.withUnsafeBytes { Data($0) }
  }
}
