import Foundation
import UIKit

class FocusAreaShapeLayer: CAShapeLayer {

  // MARK: Lifecycle

  override init() {
    super.init()
    configureLayerAppearance()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureLayerAppearance()
  }

  // MARK: Internal

  func move(to coordinates: [CGPoint]) {
    let currentTime = Date().timeIntervalSince1970
    guard currentTime - focusAreaLastUpdateTime > debounceFocusAreaTime else { return }
    focusAreaLastUpdateTime = currentTime

    let newPath = computePath(from: coordinates)
    guard path != newPath.cgPath else { return }

    applyPathAnimation(newPath: newPath)
    path = newPath.cgPath
  }

  func resetPositionToCenter(of view: UIView) {
    let squareSize = defaultSize
    let centerX = view.bounds.midX
    let centerY = view.bounds.midY

    let topLeftCorner = CGPoint(x: centerX - squareSize / 2, y: centerY - squareSize / 2)

    let coordinates = createSquareCoordinates(from: topLeftCorner, size: squareSize)
    move(to: coordinates)
  }

  // MARK: Private

  private let animationPathKey = "animationPath"
  private let animationKey = "path"
  private let animationDuration: TimeInterval = 0.200

  private let defaultSize: CGFloat = 200

  private let focusAreaLineLength: CGFloat = 40

  /// limits: [0.01:0.5]
  /// 0.01 being a shaper (but slightly rounded) edge
  /// 0.5 being softly rounded curvature
  /// each angle of the shape is controlled by 2 control points sharing the same offset on x & y.
  private let controlPointOffset: CGFloat = 0.05

  private var focusAreaLastUpdateTime: TimeInterval = 0
  private let debounceFocusAreaTime: TimeInterval = 0.2

  private func configureLayerAppearance() {
    strokeColor = UIColor.white.cgColor
    fillColor = UIColor.clear.cgColor
    lineWidth = 5.0
    lineCap = .round
    cornerRadius = 12

    shadowColor = UIColor.black.cgColor
    shadowOffset = CGSize(width: 1, height: 1)
    shadowOpacity = 0.5
    shadowRadius = 1.0
  }

  private func applyPathAnimation(newPath: UIBezierPath) {
    removeAnimation(forKey: animationPathKey)

    let animation = CABasicAnimation(keyPath: animationKey)
    animation.duration = animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.fromValue = path
    animation.toValue = newPath.cgPath
    add(animation, forKey: animationPathKey)
  }

  private func createSquareCoordinates(from topLeft: CGPoint, size: CGFloat) -> [CGPoint] {
    [
      topLeft,
      CGPoint(x: topLeft.x + size, y: topLeft.y),
      CGPoint(x: topLeft.x + size, y: topLeft.y + size),
      CGPoint(x: topLeft.x, y: topLeft.y + size),
    ]
  }

  private func computePath(from coordinates: [CGPoint]) -> UIBezierPath {
    guard coordinates.count == 4 else { return UIBezierPath() }

    let path = UIBezierPath()

    for i in 0..<coordinates.count {
      let startPoint = coordinates[i]
      let nextPoint = coordinates[(i + 1) % 4]
      let previousPoint = coordinates[(i + 3) % 4]

      let dynamicLineLengthNext = min(focusAreaLineLength, distanceBetween(startPoint, nextPoint) / 4)
      let dynamicLineLengthPrev = min(focusAreaLineLength, distanceBetween(startPoint, previousPoint) / 4)

      let nextVector = normalizedVector(from: startPoint, to: nextPoint, length: dynamicLineLengthNext)
      let previousVector = normalizedVector(from: startPoint, to: previousPoint, length: dynamicLineLengthPrev)

      let nextLineEnd = CGPoint(x: startPoint.x + nextVector.x, y: startPoint.y + nextVector.y)
      let previousLineEnd = CGPoint(x: startPoint.x + previousVector.x, y: startPoint.y + previousVector.y)

      path.move(to: previousLineEnd)

      let firstControlPoint = CGPoint(
        x: startPoint.x + previousVector.x * controlPointOffset,
        y: startPoint.y + previousVector.y * controlPointOffset)

      let secondControlPoint = CGPoint(
        x: startPoint.x + nextVector.x * controlPointOffset,
        y: startPoint.y + nextVector.y * controlPointOffset)

      path.addCurve(to: nextLineEnd, controlPoint1: firstControlPoint, controlPoint2: secondControlPoint)
    }

    return path
  }

  private func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    hypot(point2.x - point1.x, point2.y - point1.y)
  }

  private func normalizedVector(from startPoint: CGPoint, to endPoint: CGPoint, length: CGFloat) -> CGPoint {
    let vector = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
    let vectorLength = hypot(vector.x, vector.y)
    return CGPoint(x: (vector.x / vectorLength) * length, y: (vector.y / vectorLength) * length)
  }
}
