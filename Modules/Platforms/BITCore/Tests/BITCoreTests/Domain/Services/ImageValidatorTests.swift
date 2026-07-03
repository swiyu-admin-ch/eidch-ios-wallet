import Factory
import XCTest
@testable import BITCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class ImageValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.supportedImageType.register { self.supportedImageTypes }
    validator = ImageValidator()
  }

  func testValidate_pngImage_success() throws {
    XCTAssertNoThrow(try validator.validate(base64Image: mockPngBase64, against: .imagePng))
  }

  func testValidate_jpegImage_success() throws {
    XCTAssertNoThrow(try validator.validate(base64Image: mockJpegBase64, against: .imageJpg))
  }

  func testValidate_unsupportedImage_throwsError() throws {
    Container.shared.supportedImageType.register { [.imagePng] }
    validator = ImageValidator()

    XCTAssertThrowsError(try validator.validate(base64Image: mockJpegBase64, against: .imageJpg)) { error in
      XCTAssertEqual(error as? ImageValidatorError, .unsupportedImageFormat)
    }
  }

  func testValidate_invalidImageData_throwsError() throws {
    Container.shared.supportedImageType.register { [.imagePng, .imageJpg, .boolean] }
    validator = ImageValidator()

    XCTAssertThrowsError(try validator.validate(base64Image: mockJpegBase64, against: .boolean)) { error in
      XCTAssertEqual(error as? ImageValidatorError, .invalidImageData)
    }
  }

  func testValidate_mismatchImageFormat_throwsError() throws {
    XCTAssertThrowsError(try validator.validate(base64Image: mockPngBase64, against: .imageJpg)) { error in
      XCTAssertEqual(error as? ImageValidatorError, .mismatchingImageFormat)
    }
  }

  // MARK: Private

  private var validator: ImageValidator!
  private var supportedImageTypes: [ValueType] = [.imageJpg, .imagePng]
  private let mockPngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
  private let mockJpegBase64 = "/9j/4AAQSkZJRgAB"
}
