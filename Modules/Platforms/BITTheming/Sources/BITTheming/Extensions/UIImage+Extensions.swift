import SwiftUI

extension UIImage {

  public func rotated(by rotationAngle: Angle) -> UIImage? {
    guard let cgImage else { return nil }

    let rotationInRadians = CGFloat(rotationAngle.radians)
    let transform = CGAffineTransform(rotationAngle: rotationInRadians)
    var rect = CGRect(origin: .zero, size: size).applying(transform)
    rect.origin = .zero

    let renderer = UIGraphicsImageRenderer(size: rect.size)
    return renderer.image { renderContext in
      renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
      renderContext.cgContext.rotate(by: rotationInRadians)
      renderContext.cgContext.scaleBy(x: 1.0, y: -1.0)

      let drawRect = CGRect(
        origin: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2),
        size: self.size)
      renderContext.cgContext.draw(cgImage, in: drawRect)
    }
  }
}
