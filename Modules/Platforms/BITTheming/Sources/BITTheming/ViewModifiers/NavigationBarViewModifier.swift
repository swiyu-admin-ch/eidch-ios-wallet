import SwiftUI

// MARK: - NavigationBarAppearanceViewModifier

public struct NavigationBarAppearanceViewModifier: ViewModifier {
  let appearance: UINavigationBarAppearance
  let scrollEdgeAppearance: UINavigationBarAppearance?

  public init(appearance: UINavigationBarAppearance, scrollEdgeAppearance: UINavigationBarAppearance? = nil) {
    self.appearance = appearance
    self.scrollEdgeAppearance = scrollEdgeAppearance == nil ? appearance : scrollEdgeAppearance
  }

  public func body(content: Content) -> some View {
    content
      .background(
        NavigationView { viewController in
          viewController.applyNavigationAppearance(appearance, scrollEdgeAppearance: scrollEdgeAppearance)
        }
      )
  }
}

extension View {
  public func navigationBar(_ appearance: UINavigationBarAppearance, scrollEdgeAppearance: UINavigationBarAppearance? = nil) -> some View {
    modifier(NavigationBarAppearanceViewModifier(appearance: appearance, scrollEdgeAppearance: scrollEdgeAppearance))
  }
}

// MARK: - NavigationView

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
