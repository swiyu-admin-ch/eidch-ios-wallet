import Factory
import SwiftUI
import UIKit

// MARK: - NoDevicePinCodeModuleWrapper

public struct NoDevicePinCodeModuleWrapper: View {

  // MARK: Lifecycle

  public init(didReceiveDevicePinCode: @escaping () -> Void) {
    self.didReceiveDevicePinCode = didReceiveDevicePinCode
  }

  // MARK: Public

  public var body: some View {
    NoDevicePinCodeModuleRepresentable(didReceiveDevicePinCode: didReceiveDevicePinCode)
      .ignoresSafeArea()
  }

  // MARK: Private

  private let didReceiveDevicePinCode: () -> Void
}

// MARK: - NoDevicePinCodeModuleRepresentable

private struct NoDevicePinCodeModuleRepresentable: UIViewControllerRepresentable {

  // MARK: Lifecycle

  init(didReceiveDevicePinCode: @escaping () -> Void) {
    self.didReceiveDevicePinCode = didReceiveDevicePinCode
  }

  // MARK: Internal

  @MainActor
  final class Coordinator: NSObject, NoDevicePinCodeDelegate {

    // MARK: Lifecycle

    init(didReceiveDevicePinCode: @escaping () -> Void) {
      self.didReceiveDevicePinCode = didReceiveDevicePinCode
      super.init()
      module.viewModel.delegate = self
    }

    // MARK: Internal

    let module = Container.shared.noDevicePinCodeModule()

    func didCompleteNoDevicePinCode() {
      didReceiveDevicePinCode()
    }

    // MARK: Private

    private let didReceiveDevicePinCode: () -> Void

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(didReceiveDevicePinCode: didReceiveDevicePinCode)
  }

  func makeUIViewController(context: Context) -> UIViewController {
    context.coordinator.module.viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

  // MARK: Private

  private let didReceiveDevicePinCode: () -> Void
}
