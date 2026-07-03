import XCTest
@testable import BITCredential

final class ValueTypeResolverTests: XCTestCase {

  // MARK: Internal

  func testCallAsFunction_nilValue_returnsNil() {
    let resolved = resolver(nil)

    XCTAssertNil(resolved)
  }

  func testCallAsFunction_boolValue_returnsBoolean() {
    let resolved = resolver(true)

    XCTAssertEqual(resolved, .boolean)
  }

  func testCallAsFunction_integerValue_returnsNumeric() {
    let resolved = resolver(165)

    XCTAssertEqual(resolved, .numeric)
  }

  func testCallAsFunction_doubleValue_returnsNumeric() {
    let resolved = resolver(1.65)

    XCTAssertEqual(resolved, .numeric)
  }

  func testCallAsFunction_stringPngDataURL_returnsImagePng() {
    let resolved = resolver(Self.pngDataURL)

    XCTAssertEqual(resolved, .imagePng)
  }

  func testCallAsFunction_stringJpgDataURL_returnsImageJpg() {
    let resolved = resolver(Self.jpgDataURL)

    XCTAssertEqual(resolved, .imageJpg)
  }

  func testCallAsFunction_invalidDataURL_returnsString() {
    let invalidDataTypeURL = "data:image/gif;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2w=="

    let resolved = resolver(invalidDataTypeURL)

    XCTAssertEqual(resolved, .string)
  }

  func testCallAsFunction_jpgBase64Image_returnsImageJpg() {
    let resolved = resolver("/9j/4AAQSkZJRgAB")

    XCTAssertEqual(resolved, .imageJpg)
  }

  func testCallAsFunction_pngBase64Image_returnsImagePng() {
    let resolved = resolver("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=")

    XCTAssertEqual(resolved, .imagePng)
  }

  func testCallAsFunction_stringIsoDate_returnsDateTime() {
    let dateTimes = [
      "2025-06-05T23:59:59.999+00:00",
      "2025-06-05T23:59:59",
      "2025-06-05",
      "2025-06",
      "2025",
      "23:59:59.999Z",
      "23:59:59",
      "23:59",
    ]

    for date in dateTimes {
      let resolved = resolver(date)
      XCTAssertEqual(resolved, .dateTime)
    }
  }

  func testCallAsFunction_plainString_returnsString() {
    let resolved = resolver("lastName")

    XCTAssertEqual(resolved, .string)
  }

  func testCallAsFunction_arrayValue_returnsNil() {
    let resolved = resolver(["one", "two"])

    XCTAssertNil(resolved)
  }

  // MARK: Private

  private static let pngDataURL = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
  private static let jpgDataURL = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2w=="

  private let resolver = ValueTypeResolver()
}
