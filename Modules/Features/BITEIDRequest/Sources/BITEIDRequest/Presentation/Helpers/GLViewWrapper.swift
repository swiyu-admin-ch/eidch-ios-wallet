import SwiftUI
import UIKit

// MARK: - GLViewWrapper

struct GLViewWrapper: UIViewRepresentable {
  let getGLView: (Int, Int) -> UIView
  let orientation: UIDeviceOrientation

  init(_ getGLView: @escaping (Int, Int) -> UIView, orientation: UIDeviceOrientation = .portrait) {
    self.getGLView = getGLView
    self.orientation = orientation
  }

  func makeUIView(context _: Context) -> ContainerView {
    ContainerView(getGLView: getGLView, orientation: orientation)
  }

  func updateUIView(_ uiView: ContainerView, context _: Context) {
    uiView.updateGLViewClosure(getGLView)
    uiView.updateOrientation(orientation)
  }
}

// MARK: - ContainerView

class ContainerView: UIView {

  // MARK: Lifecycle

  init(getGLView: @escaping (Int, Int) -> UIView, orientation: UIDeviceOrientation) {
    self.getGLView = getGLView
    self.orientation = orientation
    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func layoutSubviews() {
    super.layoutSubviews()

    let width = Int(bounds.width)
    let height = Int(bounds.height)

    guard width > 0, height > 0 else { return }

    let shouldReplaceGLView: Bool = if let glViewSize {
      glView == nil || glViewSize.0 != width || glViewSize.1 != height
    } else {
      true
    }

    if shouldReplaceGLView {
      replaceGLView(width: width, height: height)
      glViewSize = (width, height)
    }

    applyOrientationTransform()
  }

  func updateGLViewClosure(_ newClosure: @escaping (Int, Int) -> UIView) {
    getGLView = newClosure
  }

  func updateOrientation(_ newOrientation: UIDeviceOrientation) {
    guard orientation != newOrientation else { return }
    orientation = newOrientation
    setNeedsLayout()
  }

  // MARK: Private

  private var getGLView: (Int, Int) -> UIView
  private var glView: UIView?
  private var glViewSize: (Int, Int)?
  private var orientation: UIDeviceOrientation

  private func replaceGLView(width: Int, height: Int) {
    glView?.removeFromSuperview()

    let newGLView = getGLView(width, height)
    newGLView.autoresizingMask = []
    addSubview(newGLView)
    glView = newGLView
  }

  private func applyOrientationTransform() {
    guard let glView else { return }

    let angle: CGFloat = switch orientation {
    case .landscapeLeft:
      -.pi / 2
    case .landscapeRight:
      .pi / 2
    case .portraitUpsideDown:
      .pi
    default:
      0
    }

    glView.transform = .identity
    glView.bounds = CGRect(origin: .zero, size: bounds.size)

    if angle != 0 {
      glView.bounds = CGRect(origin: .zero, size: CGSize(width: bounds.height, height: bounds.width))
      glView.transform = CGAffineTransform(rotationAngle: angle)
    }

    glView.center = CGPoint(x: bounds.midX, y: bounds.midY)
  }
}
