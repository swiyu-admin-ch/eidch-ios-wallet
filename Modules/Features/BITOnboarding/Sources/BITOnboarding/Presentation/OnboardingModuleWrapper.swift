import Factory
import SwiftUI
import UIKit

// MARK: - OnboardingModuleWrapper

public struct OnboardingModuleWrapper: View {

  // MARK: Lifecycle

  public init(onFinish: @escaping () -> Void) {
    self.onFinish = onFinish
  }

  // MARK: Public

  public var body: some View {
    OnboardingModuleRepresentable(onFinish: onFinish)
      .ignoresSafeArea()
  }

  // MARK: Private

  private let onFinish: () -> Void
}

// MARK: - OnboardingModuleRepresentable

private struct OnboardingModuleRepresentable: UIViewControllerRepresentable {

  // MARK: Lifecycle

  init(onFinish: @escaping () -> Void) {
    self.onFinish = onFinish
  }

  // MARK: Internal

  @MainActor
  final class Coordinator: NSObject, OnboardingDelegate {

    // MARK: Lifecycle

    init(onFinish: @escaping () -> Void) {
      self.onFinish = onFinish
      super.init()
      module.router.context.onboardingDelegate = self
    }

    // MARK: Internal

    let module = Container.shared.onboardingModule()

    func didCompleteOnboarding() {
      onFinish()
    }

    // MARK: Private

    private let onFinish: () -> Void

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(onFinish: onFinish)
  }

  func makeUIViewController(context: Context) -> UIViewController {
    context.coordinator.module.viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

  // MARK: Private

  private let onFinish: () -> Void
}
