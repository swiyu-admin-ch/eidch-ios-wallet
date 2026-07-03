import UIKit

// MARK: - Window

final class Window: UIWindow {
  override func didUpdateFocus(
    in context: UIFocusUpdateContext,
    with coordinator: UIFocusAnimationCoordinator)
  {
    super.didUpdateFocus(in: context, with: coordinator)
    NotificationCenter.default.post(name: .windowDidUpdateFocus, object: self)
  }

  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    super.pressesBegan(presses, with: event)
    guard presses.contains(where: { $0.key != nil }) else { return }
    NotificationCenter.default.post(name: .windowPressesBegan, object: self)
  }
}
