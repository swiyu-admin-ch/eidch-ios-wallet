import CoreImage.CIFilterBuiltins
import Spyable
import UIKit

// MARK: - QRCodeGeneratorProtocol

@Spyable
public protocol QRCodeGeneratorProtocol {
  /// Generate a QR code based on the following parameters
  ///
  /// - Parameters:
  ///   - input: A string representing the data to be encoded as a QR Code
  ///   - correctionLevel: Error correction format
  ///   - scale: Scale value for output image
  /// - Returns: The generated QR Code as data
  func generate(from input: String, correctionLevel: QRCodeGeneratorCorrectionLevel, scale: CGFloat) -> Data?

  /// Generate a QR code based on the following parameters
  ///
  /// - Parameters:
  ///   - input: A string representing the data to be encoded as a QR Code
  ///   - correctionLevel: Error correction format
  ///   - scale: Scale value for output image
  /// - Returns: The generated QR Code as CIImage
  func generateImage(from input: String, correctionLevel: QRCodeGeneratorCorrectionLevel, scale: CGFloat) -> CIImage?
}

extension QRCodeGeneratorProtocol {
  public func generate(from input: String, correctionLevel: QRCodeGeneratorCorrectionLevel = .high, scale: CGFloat = 4) -> Data? {
    generate(from: input, correctionLevel: correctionLevel, scale: scale)
  }

  public func generateImage(from input: String, correctionLevel: QRCodeGeneratorCorrectionLevel = .high, scale: CGFloat = 4) -> CIImage? {
    generateImage(from: input, correctionLevel: correctionLevel, scale: scale)
  }
}

// MARK: - QRCodeGenerator

struct QRCodeGenerator: QRCodeGeneratorProtocol {

  func generateImage(from input: String, correctionLevel: QRCodeGeneratorCorrectionLevel, scale: CGFloat) -> CIImage? {
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(input.utf8)
    filter.correctionLevel = correctionLevel.rawValue
    return filter.outputImage
  }

  func generate(from input: String, correctionLevel: QRCodeGeneratorCorrectionLevel, scale: CGFloat) -> Data? {
    guard let outputImage = generateImage(from: input, correctionLevel: correctionLevel, scale: scale) else {
      return nil
    }

    let transform = CGAffineTransform(scaleX: scale, y: scale)
    let scaledImage = outputImage.transformed(by: transform)
    let context = CIContext()

    guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
      return nil
    }

    return UIImage(cgImage: cgImage).pngData()
  }

}

// MARK: - QRCodeGeneratorCorrectionLevel

public enum QRCodeGeneratorCorrectionLevel: String {
  case low = "L" // 7
  case medium = "M" // 15
  case quartile = "Q" // 25
  case high = "H" // 30
}
