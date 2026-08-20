import SwiftUI

// MARK: - External Keyboard Shortcuts

extension View {
  /// Custom version of SwiftUI's `keyboardShortcut`.
  /// However, this one allows us to catch external keyboard key presses also from views contained inside a SwiftUI List
  public func externalKeyboardShortcut(_ keys: UIKeyboardHIDUsage..., to completion: @escaping () -> Void) -> some View {
    modifier(ExternalKeyboardShortcutModifier(keys: keys, completion: completion))
  }
}

// MARK: - ExternalKeyboardShortcutModifier

private struct ExternalKeyboardShortcutModifier: ViewModifier {

  // MARK: Internal

  let keys: [UIKeyboardHIDUsage]
  let completion: () -> Void

  func body(content: Content) -> some View {
    ExternalKeyboardShortcutContainer(keys: keys, content: { content }, completion: completion)
  }
}

// MARK: - ExternalKeyboardShortcutContainer

/// Wraps the content into a UIKit layer to capture keyboard activities.
/// Necessary since SwiftUI's List captures all keyboard activities normaly provided by
/// `onKeyPress` or `keyboardShortcut` modifiers
private struct ExternalKeyboardShortcutContainer<Content: View>: UIViewControllerRepresentable {

  let keys: [UIKeyboardHIDUsage]
  @ViewBuilder
  let content: Content
  let completion: () -> Void

  func makeUIViewController(context: Context) -> ExternalKeyboardShortcutHostingController<Content> {
    ExternalKeyboardShortcutHostingController(rootView: content, keys: keys, completion: completion)
  }

  func updateUIViewController(_ uiViewController: ExternalKeyboardShortcutHostingController<Content>, context: Context) {
    uiViewController.rootView = content
    uiViewController.keys = keys
    uiViewController.completion = completion
  }

  /// Ensures that UIHostingController's rootView is rendered properly in the List
  func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: ExternalKeyboardShortcutHostingController<Content>, context: Context) -> CGSize? {
    guard let width = proposal.width, width.isFinite else { return nil }
    let fittingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
    let sizeThatFits = uiViewController.sizeThatFits(in: fittingSize)
    return CGSize(width: width, height: sizeThatFits.height)
  }
}

// MARK: - ExternalKeyboardShortcutHostingController

private final class ExternalKeyboardShortcutHostingController<Content: View>: UIHostingController<Content> {

  // MARK: Lifecycle

  init(rootView: Content, keys: [UIKeyboardHIDUsage], completion: @escaping () -> Void) {
    self.keys = keys
    self.completion = completion
    super.init(rootView: rootView)
    view.backgroundColor = .clear
    // Ensures that UIHostingController's rootView is rendered properly in the List
    sizingOptions = .intrinsicContentSize
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var completion: () -> Void
  var keys: [UIKeyboardHIDUsage]

  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    guard
      let keyCode = presses.first?.key?.keyCode,
      keys.contains(keyCode)
    else {
      super.pressesBegan(presses, with: event)
      return
    }

    completion()
  }
}
