import SwiftUI

// MARK: - NavigationBarAppearanceViewModifier

public struct NavigationBarAppearanceViewModifier: ViewModifier {
  let appearance: UINavigationBarAppearance

  public func body(content: Content) -> some View {
    content
      .background(
        NavigationView { viewController in
          viewController.applyNavigationAppearance(appearance)
        }
      )
  }
}

extension View {
  public func navigationBar(_ appearance: UINavigationBarAppearance) -> some View {
    modifier(NavigationBarAppearanceViewModifier(appearance: appearance))
  }
}

private struct NavigationView: UIViewControllerRepresentable {
  let configure: (UIViewController) -> Void

  func makeUIViewController(context: Context) -> UIViewController {
    let viewController = UIViewController()
    DispatchQueue.main.async {
      configure(viewController)
    }
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    DispatchQueue.main.async {
      configure(uiViewController)
    }
  }
}
