import Foundation
import XCTest
@testable import BITCore

final class ValueTypeByteSignatureTests: XCTestCase {

  // MARK: Internal

  func testMatchesByteSignature_matchingPngData_returnsTrue() throws {
    let data = try XCTUnwrap(Data(base64Encoded: Self.pngBase64))

    XCTAssertTrue(ValueType.imagePng.matchesByteSignature(of: data))
  }

  func testMatchesByteSignature_nonImageValueType_returnsFalse() throws {
    let data = try XCTUnwrap(Data(base64Encoded: Self.jpgBase64))

    XCTAssertFalse(ValueType.boolean.matchesByteSignature(of: data))
  }

  // MARK: Private

  private static let pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
  private static let jpgBase64 = "/9j/4AAQSkZJRgAB"
}
