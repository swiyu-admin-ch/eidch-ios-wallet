// swiftlint: disable force_unwrapping
import XCTest
@testable import BITCore

final class URLExtensionsTests: XCTestCase {

  // MARK: Internal

  func testDataURL_validPng_returnsBase64DataAndType() throws {
    let dataUrl = URL(string: "data:\(Self.pngType);base64,\(Self.dataMock)")!

    XCTAssertTrue(dataUrl.isDataURL)
    XCTAssertEqual(dataUrl.dataURLDataString, Self.dataMock)
    XCTAssertEqual(dataUrl.dataURLData, Data(base64Encoded: Self.dataMock))
    XCTAssertEqual(dataUrl.mediaType, Self.pngType)
  }

  func testDataURL_noBase64_returnsDataAndType() throws {
    let dataUrl = URL(string: "data:\(Self.pngType),\(Self.dataMock)")!

    XCTAssertTrue(dataUrl.isDataURL)
    XCTAssertEqual(dataUrl.dataURLDataString, Self.dataMock)
    XCTAssertEqual(dataUrl.dataURLData, Self.dataMock.data(using: .utf8))
    XCTAssertEqual(dataUrl.mediaType, Self.pngType)
  }

  func testDataURL_noMediaType_returnsBase64DataAndNilType() throws {
    let dataUrl = URL(string: "data:;base64,\(Self.dataMock)")!

    XCTAssertTrue(dataUrl.isDataURL)
    XCTAssertEqual(dataUrl.dataURLDataString, Self.dataMock)
    XCTAssertEqual(dataUrl.dataURLData, Data(base64Encoded: Self.dataMock))
    XCTAssertNil(dataUrl.mediaType)
  }

  func testDataURL_noMediaTypeAndNoBase64_returnsDataAndNilType() throws {
    let dataUrl = URL(string: "data:,\(Self.dataMock)")!

    XCTAssertTrue(dataUrl.isDataURL)
    XCTAssertEqual(dataUrl.dataURLDataString, Self.dataMock)
    XCTAssertEqual(dataUrl.dataURLData, Self.dataMock.data(using: .utf8))
    XCTAssertNil(dataUrl.mediaType)
  }

  func testDataURL_noMediaTypeNoBase64EmptyData_returnsEmptyDataAndNilType() throws {
    let dataUrl = URL(string: "data:,")!

    XCTAssertTrue(dataUrl.isDataURL)
    XCTAssertEqual(dataUrl.dataURLDataString, "")
    XCTAssertTrue(dataUrl.dataURLData?.isEmpty == true)
    XCTAssertNil(dataUrl.mediaType)
  }

  func testDataURL_malformed_returnsNil() throws {
    let dataUrl = URL(string: "malformed")!

    XCTAssertFalse(dataUrl.isDataURL)
    XCTAssertNil(dataUrl.dataURLDataString)
    XCTAssertNil(dataUrl.dataURLData)
    XCTAssertNil(dataUrl.mediaType)
  }

  func testDataURL_emptyString_returnsNil() throws {
    let dataUrl = URL(string: "")

    XCTAssertNil(dataUrl)
  }

  func testDataURL_invalidDataURL_returnsNil() throws {
    for url in Self.invalidDataURLs {
      let dataUrl = URL(string: url)!

      XCTAssertFalse(dataUrl.isDataURL)
      XCTAssertNil(dataUrl.dataURLDataString)
      XCTAssertNil(dataUrl.dataURLData)
      XCTAssertNil(dataUrl.mediaType)
    }
  }

  // MARK: Private

  private static let pngType = "image/png"
  private static let dataMock = "data"
  private static let invalidDataURLs = [
    "dat:\(pngType);base64,\(dataMock)",
    "data\(pngType);base64,\(dataMock)",
    "data:invalid#;base64,\(dataMock)",
    "data:\(pngType);bas64,\(dataMock)",
    "data:\(pngType);base64\(dataMock)",
  ]
}

// swiftlint:enable all
