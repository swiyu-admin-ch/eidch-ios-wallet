import CoreImage
import Metal
import MetalKit

// MARK: - EdrRenderer

/// Renders EDR-capable CIImages into a Metal-backed view.
class EdrRenderer: NSObject, MTKViewDelegate {

  // MARK: Lifecycle

  init(imageProvider: @escaping (_ contentScaleFactor: CGFloat, _ headroom: CGFloat, _ size: CGFloat) -> CIImage?) {
    self.imageProvider = imageProvider
    commandQueue = device?.makeCommandQueue()

    if let commandQueue {
      renderContext = CIContext(
        mtlCommandQueue: commandQueue,
        options: [
          .name: "Renderer",
          .cacheIntermediates: true,
          .allowLowPower: true,
        ])
    } else {
      renderContext = nil
    }
    super.init()
  }

  // MARK: Internal

  let device: MTLDevice? = MTLCreateSystemDefaultDevice()

  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

  func draw(in view: MTKView) {
    guard let commandQueue, let renderContext else { return }

    renderQueue.wait()
    defer { renderQueue.signal() }

    guard let drawable = view.currentDrawable else { return }

    let scale = view.contentScaleFactor
    let headroom: CGFloat = view.window?.screen.currentEDRHeadroom ?? 1.0

    let size = min(view.drawableSize.width, view.drawableSize.height) / scale
    guard var image = imageProvider(scale, headroom, size) else { return }

    let imageRect = image.extent
    let bounds = CGRect(origin: .zero, size: view.drawableSize)
    let shift = CGAffineTransform(
      translationX: (bounds.width - imageRect.width) / 2,
      y: (bounds.height - imageRect.height) / 2)
    image = image.transformed(by: shift)

    let commandBuffer = commandQueue.makeCommandBuffer()
    let destination = CIRenderDestination(
      width: Int(bounds.width),
      height: Int(bounds.height),
      pixelFormat: view.colorPixelFormat,
      commandBuffer: commandBuffer,
      mtlTextureProvider: { drawable.texture })

    if let commandBuffer {
      _ = try? renderContext.startTask(toRender: image, from: bounds, to: destination, at: .zero)
      commandBuffer.present(drawable)
      commandBuffer.commit()
    }
  }

  // MARK: Private

  private let commandQueue: MTLCommandQueue?
  private let renderContext: CIContext?
  private let renderQueue = DispatchSemaphore(value: 3)
  private let imageProvider: (_ scale: CGFloat, _ headroom: CGFloat, _ size: CGFloat) -> CIImage?

}
