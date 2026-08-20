import SwiftUI
import UIKit

// MARK: - SplashScreenWrapper

struct SplashScreenWrapper: UIViewControllerRepresentable {
  @MainActor
  final class Coordinator: NSObject, SplashScreenDelegate {

    // MARK: Lifecycle

    init(onFinish: @escaping () -> Void) {
      self.onFinish = onFinish
    }

    // MARK: Internal

    func didCompleteSplashScreen() {
      onFinish()
    }

    // MARK: Private

    private let onFinish: () -> Void

  }

  let onFinish: () -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onFinish: onFinish)
  }

  func makeUIViewController(context: Context) -> UIViewController {
    let viewController = AnimatedSplashScreenHostingController()
    viewController.delegate = context.coordinator
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
