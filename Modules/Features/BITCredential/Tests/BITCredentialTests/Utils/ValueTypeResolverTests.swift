import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential

class ValueTypeResolverTests: XCTestCase {

  // MARK: Internal

  func testCallAsFunction_nilValue_returnsNil() {
    let claim = createAnyClaim(value: nil)

    let valueType = resolver(claim)

    XCTAssertNil(valueType)
  }

  func testCallAsFunction_boolValue_returnsBoolean() {
    let claim = createAnyClaim(value: .bool(true))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .boolean)
  }

  func testCallAsFunction_integerValue_returnsNumeric() {
    let claim = createAnyClaim(value: .int(165))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .numeric)
  }

  func testCallAsFunction_doubleValue_returnsNumeric() {
    let claim = createAnyClaim(value: .double(1.65))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .numeric)
  }

  func testCallAsFunction_stringPngDataURL_returnsImagePng() {
    let claim = createAnyClaim(value: .string(Self.pngDataURL))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .imagePng)
  }

  func testCallAsFunction_stringJpgDataURL_returnsImageJpg() {
    let claim = createAnyClaim(value: .string(Self.jpgDataURL))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .imageJpg)
  }

  func testCallAsFunction_invalidDataURL_returnsString() {
    let invalidDataTypeURL = "data:image/gif;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2w=="
    let claim = createAnyClaim(value: .string(invalidDataTypeURL))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .string)
  }

  func testCallAsFunction_JpgBase64Image_returnsImageJpg() {
    let base64Jpg = "/9j/4AAQSkZJRgAB"
    let claim = createAnyClaim(value: .string(base64Jpg))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .imageJpg)
  }

  func testCallAsFunction_pngBase64Image_returnsImagePng() {
    let base64Png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
    let claim = createAnyClaim(value: .string(base64Png))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .imagePng)
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
      let claim = createAnyClaim(value: .string(date))
      let valueType = resolver(claim)
      XCTAssertEqual(valueType, .dateTime)
    }
  }

  func testCallAsFunction_plainString_returnsString() {
    let claim = createAnyClaim(value: .string("lastName"))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .string)
  }

  func testCallAsFunction_arrayValue_returnsString() {
    let claim = createAnyClaim(value: .array([.string("one"), .string("two")]))

    let valueType = resolver(claim)

    XCTAssertEqual(valueType, .string)
  }

  // MARK: Private

  private static let pngDataURL = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
  private static let jpgDataURL = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2w=="

  private let resolver = ValueTypeResolver()

  private func createAnyClaim(value: CodableValue?) -> AnyClaimSpy {
    let claim = AnyClaimSpy()
    claim.key = "key"
    claim.path = [.string("key")]
    claim.value = value
    return claim
  }
}
