// MARK: - EdrQRCodeCoordinator

public final class EdrQRCodeCoordinator {

  // MARK: Lifecycle

  init(content: String, correctionLevel: QRCodeGeneratorCorrectionLevel, qrCodeGenerator: QRCodeGeneratorProtocol) {
    provider = EdrQRCodeProvider(
      content: content,
      correctionLevel: correctionLevel,
      qrCodeGenerator: qrCodeGenerator)
    renderer = EdrRenderer { [provider] scaleFactor, headroom, size in
      provider.image(scaleFactor: scaleFactor, headroom: headroom, size: size)
    }
  }

  // MARK: Internal

  let renderer: EdrRenderer

  func update(content: String, correctionLevel: QRCodeGeneratorCorrectionLevel, qrCodeGenerator: QRCodeGeneratorProtocol) {
    provider.content = content
    provider.correctionLevel = correctionLevel
    provider.qrCodeGenerator = qrCodeGenerator
  }

  // MARK: Private

  private let provider: EdrQRCodeProvider

}
