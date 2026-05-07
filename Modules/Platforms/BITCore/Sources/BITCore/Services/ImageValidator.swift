import Factory
import Foundation
import Spyable

// MARK: - ImageValidatorProtocol

@Spyable
public protocol ImageValidatorProtocol {
  /// Validates that an image payload matches the expected image format based on the file magic numbers
  /// https://gist.github.com/leommoore/f9e57ba2aa4bf197ebc5
  ///
  /// The method decodes the Base64-encoded `image` and compares its leading
  /// bytes (file signature / magic bytes) with the signature for `valueType`.
  ///
  /// - Parameters:
  ///   - base64Image: A Base64-encoded image payload.
  ///   - valueType: The expected image type (for example, `.imagePng` or `.imageJpg`).
  /// - Throws:
  ///   - `ImageValidatorError.unsupportedImageFormat` if `valueType` is not in the
  ///     configured list of supported image formats.
  ///   - `ImageValidatorError.invalidImageData` if `image` is not valid Base64 data
  ///     or if `valueType` is not an image type.
  ///   - `ImageValidatorError.mismatchingImageFormat` if the decoded image signature
  ///     does not match `valueType`.
  func validate(base64Image: String, against valueType: ValueType) throws
}

// MARK: - ImageValidator

struct ImageValidator: ImageValidatorProtocol {

  // MARK: Internal

  func validate(base64Image: String, against valueType: ValueType) throws {
    guard imageValidatorEnabled else {
      return
    }

    if !supportedImageType.contains(valueType) {
      throw ImageValidatorError.unsupportedImageFormat
    }

    guard
      valueType.byteSignature != nil,
      let data = Data(base64Encoded: base64Image)
    else {
      throw ImageValidatorError.invalidImageData
    }

    if !valueType.matchesByteSignature(of: data) {
      throw ImageValidatorError.mismatchingImageFormat
    }
  }

  // MARK: Private

  @Injected(\.supportedImageType) private var supportedImageType
  @Injected(\.imageValidatorEnabled) private var imageValidatorEnabled
}

// MARK: - ImageValidatorError

enum ImageValidatorError: Error {
  case mismatchingImageFormat
  case invalidImageData
  case unsupportedImageFormat
}
