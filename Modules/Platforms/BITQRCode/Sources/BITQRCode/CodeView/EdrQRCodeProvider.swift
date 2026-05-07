import CoreImage

// MARK: - EdrQRCodeProvider

final class EdrQRCodeProvider {

  // MARK: Lifecycle

  init(content: String, correctionLevel: QRCodeGeneratorCorrectionLevel, qrCodeGenerator: QRCodeGeneratorProtocol) {
    self.content = content
    self.correctionLevel = correctionLevel
    self.qrCodeGenerator = qrCodeGenerator
  }

  // MARK: Internal

  var content: String
  var correctionLevel: QRCodeGeneratorCorrectionLevel
  var qrCodeGenerator: QRCodeGeneratorProtocol

  func image(scaleFactor: CGFloat, headroom: CGFloat, size: CGFloat) -> CIImage? {
    guard size > 0 else { return nil }
    guard
      var image = qrCodeGenerator.generateImage(from: content, correctionLevel: correctionLevel) else { return nil }

    let sizeTransform = CGAffineTransform(
      scaleX: size * (scaleFactor / image.extent.size.width),
      y: size * (scaleFactor / image.extent.size.height))
    image = image.transformed(by: sizeTransform)

    guard
      let colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB),
      let maxFillColor = CIColor(red: headroom, green: headroom, blue: headroom, colorSpace: colorSpace)
    else {
      return nil
    }

    let fillImage = CIImage(color: maxFillColor)
    let maskFilter = CIFilter.blendWithMask()
    maskFilter.maskImage = image
    maskFilter.inputImage = fillImage

    return maskFilter.outputImage?.cropped(
      to: CGRect(
        x: 0,
        y: 0,
        width: size * scaleFactor,
        height: size * scaleFactor))
  }

}
