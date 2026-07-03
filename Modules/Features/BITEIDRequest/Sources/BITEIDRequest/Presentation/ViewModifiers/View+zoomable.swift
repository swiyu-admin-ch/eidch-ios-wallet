import SwiftUI

extension View {
  public func zoomable() -> some View {
    ZoomableScrollView(content: { self })
  }
}

// MARK: - ZoomableScrollView

private struct ZoomableScrollView<Content: View>: UIViewRepresentable {

  // MARK: Lifecycle

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  // MARK: Internal

  // MARK: - Coordinator

  class Coordinator: NSObject, UIScrollViewDelegate {

    // MARK: Lifecycle

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    // MARK: Internal

    var hostingController: UIHostingController<Content>

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      hostingController.view
    }
  }

  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator
    scrollView.maximumZoomScale = 8
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false

    let hostedView = context.coordinator.hostingController.view
    hostedView?.translatesAutoresizingMaskIntoConstraints = true
    hostedView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView?.frame = scrollView.bounds

    if let hostedView {
      scrollView.addSubview(hostedView)
    }

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(hostingController: UIHostingController(rootView: content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    context.coordinator.hostingController.rootView = content
  }

  // MARK: Private

  private var content: Content

}
