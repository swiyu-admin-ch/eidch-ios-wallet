import Factory
import Testing
@testable import BITCore

struct ImageValidatorTests {

  // MARK: Lifecycle

  init() {
    let supportedImageTypes: [ValueType] = [.imageJpg, .imagePng]
    self.supportedImageTypes = supportedImageTypes

    Container.shared.supportedImageType.register { supportedImageTypes }

    validator = ImageValidator()
  }

  // MARK: Internal

  @Test
  func validate_pngImage_success() throws {
    try validator.validate(base64Image: mockPngBase64, against: .imagePng)
    #expect(true)
  }

  @Test
  func validate_jpegImage_success() throws {
    try validator.validate(base64Image: mockJpegBase64, against: .imageJpg)
    #expect(true)
  }

  @Test
  func validate_unsupportedImage_throwsError() throws {
    Container.shared.supportedImageType.register { [.imagePng] }
    let validator = ImageValidator()

    #expect(throws: ImageValidatorError.unsupportedImageFormat) {
      try validator.validate(base64Image: mockJpegBase64, against: .imageJpg)
    }
  }

  @Test
  func validate_invalidImageData_throwsError() throws {
    Container.shared.supportedImageType.register { [.imagePng, .imageJpg, .boolean] }
    let validator = ImageValidator()

    #expect(throws: ImageValidatorError.invalidImageData) {
      try validator.validate(base64Image: mockJpegBase64, against: .boolean)
    }
  }

  @Test
  func validate_mismatchImageFormat_throwsError() throws {
    #expect(throws: ImageValidatorError.mismatchingImageFormat) {
      try validator.validate(base64Image: mockPngBase64, against: .imageJpg)
    }
  }

  // MARK: Private

  private var validator: ImageValidator
  private var supportedImageTypes: [ValueType]
  private let mockPngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
  private let mockJpegBase64 = "/9j/4AAQSkZJRgAB"
}
