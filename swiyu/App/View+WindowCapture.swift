import SwiftUI
import UIKit

extension View {
  func captureWindow(_ onResolve: @escaping (UIWindow) -> Void) -> some View {
    modifier(WindowCaptureModifier(onResolve: onResolve))
  }
}

// MARK: - WindowCaptureModifier

private struct WindowCaptureModifier: ViewModifier {
  let onResolve: (UIWindow) -> Void

  func body(content: Content) -> some View {
    content.background(WindowCaptureView(onResolve: onResolve))
  }
}

// MARK: - WindowCaptureView

private struct WindowCaptureView: UIViewRepresentable {
  let onResolve: (UIWindow) -> Void

  func makeUIView(context: Context) -> WindowCaptureUIView {
    let view = WindowCaptureUIView()
    view.onResolve = onResolve
    return view
  }

  func updateUIView(_ uiView: WindowCaptureUIView, context: Context) {
    uiView.onResolve = onResolve
    uiView.resolveWindowIfNeeded()
  }
}

// MARK: - WindowCaptureUIView

private final class WindowCaptureUIView: UIView {
  var onResolve: ((UIWindow) -> Void)?

  override func didMoveToWindow() {
    super.didMoveToWindow()
    resolveWindowIfNeeded()
  }

  func resolveWindowIfNeeded() {
    guard let window else { return }
    onResolve?(window)
  }
}
