import Foundation
import UIKit

extension UIImage {
  public func detectQRImage(ofType type: String, options: [String: String] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]) -> UIImage? {
    guard let ciImage = CIImage(image: self) else { return nil }
    let detector = CIDetector(ofType: type, context: nil, options: options)
    guard let feature = detector?.features(in: ciImage).first as? CIQRCodeFeature else { return nil }

    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -ciImage.extent.size.height)

    let path = UIBezierPath()
    path.move(to: feature.topLeft.applying(transform))
    path.addLine(to: feature.topRight.applying(transform))
    path.addLine(to: feature.bottomRight.applying(transform))
    path.addLine(to: feature.bottomLeft.applying(transform))
    path.close()

    return crop(path)
  }

  public func crop(_ path: UIBezierPath) -> UIImage? {
    let rect = CGRect(origin: CGPoint(), size: CGSize(width: size.width * scale, height: size.height * scale))

    UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
    UIColor.clear.setFill()
    UIRectFill(rect)
    path.addClip()
    draw(in: rect)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let cropRect = CGRect(
      x: path.bounds.origin.x * scale,
      y: path.bounds.origin.y * scale,
      width: path.bounds.size.width * scale,
      height: path.bounds.size.height * scale)
    guard let croppedImage = image?.cgImage?.cropping(to: cropRect) else { return nil }
    return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
  }
}
