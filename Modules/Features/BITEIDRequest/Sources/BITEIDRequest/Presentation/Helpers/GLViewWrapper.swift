import SwiftUI

// MARK: - GLViewWrapper

struct GLViewWrapper: UIViewRepresentable {
  let getGLView: (Int, Int) -> UIView

  init(_ getGLView: @escaping (Int, Int) -> UIView) {
    self.getGLView = getGLView
  }

  func makeUIView(context _: Context) -> ContainerView {
    ContainerView(getGLView: getGLView)
  }

  func updateUIView(_ uiView: ContainerView, context _: Context) {
    // Update if the getGLView closure changes
    uiView.updateGLViewClosure(getGLView)
  }
}

// MARK: - ContainerView

class ContainerView: UIView {

  // MARK: Lifecycle

  init(getGLView: @escaping (Int, Int) -> UIView) {
    self.getGLView = getGLView
    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func layoutSubviews() {
    super.layoutSubviews()

    // Remove existing GL view
    glView?.removeFromSuperview()
    glView = nil

    // Create new GL view with current dimensions
    let width = Int(bounds.width)
    let height = Int(bounds.height)

    if width > 0, height > 0 {
      glView = getGLView(width, height)
      glView?.frame = bounds
      glView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      if let glView {
        addSubview(glView)
      }
    }
  }

  func updateGLViewClosure(_ newClosure: @escaping (Int, Int) -> UIView) {
    getGLView = newClosure
    setNeedsLayout()
  }

  // MARK: Private

  private var getGLView: (Int, Int) -> UIView
  private var glView: UIView?
}
