import Factory
import MetalKit
import SwiftUI
import UIKit

// MARK: - EdrQRCodeView

/// SwiftUI view that renders a QR code using HDR to take advantage of
/// EDR-capable screens, without making the whole screen bright.
public struct EdrQRCodeView: UIViewRepresentable {

  // MARK: Lifecycle

  public init(content: String, correctionLevel: QRCodeGeneratorCorrectionLevel) {
    self.content = content
    self.correctionLevel = correctionLevel
  }

  // MARK: Public

  public func makeUIView(context: Context) -> MTKView {
    let view = MTKView(frame: .zero, device: context.coordinator.renderer.device)
    view.delegate = context.coordinator.renderer
    view.framebufferOnly = false
    view.preferredFramesPerSecond = 10
    view.backgroundColor = .white

    if let layer = view.layer as? CAMetalLayer {
      layer.wantsExtendedDynamicRangeContent = true
      layer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
      view.colorPixelFormat = .rgba16Float
    }

    return view
  }

  public func updateUIView(_ view: MTKView, context: Context) {
    context.coordinator.update(
      content: content,
      correctionLevel: correctionLevel,
      qrCodeGenerator: qrCodeGenerator)
  }

  public func makeCoordinator() -> EdrQRCodeCoordinator {
    EdrQRCodeCoordinator(
      content: content,
      correctionLevel: correctionLevel,
      qrCodeGenerator: qrCodeGenerator)
  }

  // MARK: Private

  private let correctionLevel: QRCodeGeneratorCorrectionLevel
  private let content: String

  @Injected(\.qrCodeGenerator) private var qrCodeGenerator: QRCodeGeneratorProtocol

}
