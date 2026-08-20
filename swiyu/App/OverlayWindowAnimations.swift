import UIKit

// MARK: - OverlayWindowAnimating

@MainActor
protocol OverlayWindowAnimating: AnyObject {
  func prepareForPresentation(_ window: UIWindow)
  func dismiss(_ window: UIWindow, completion: (() -> Void)?)
}

// MARK: - OverlayWindowAnimator

@MainActor
class OverlayWindowAnimator: OverlayWindowAnimating {

  // MARK: Lifecycle

  init(
    duration: TimeInterval,
    delay: TimeInterval = 0,
    options: UIView.AnimationOptions = [.curveEaseInOut, .beginFromCurrentState])
  {
    self.duration = duration
    self.delay = delay
    self.options = options
  }

  // MARK: Internal

  final func prepareForPresentation(_ window: UIWindow) {
    isDismissing = false
    animationToken += 1
    window.layer.removeAllAnimations()
    resetWindowBeforePresentation(window)
  }

  final func dismiss(_ window: UIWindow, completion: (() -> Void)? = nil) {
    guard !isDismissing else { return }

    isDismissing = true
    animationToken += 1
    let currentAnimationToken = animationToken
    willStartDismissal(window)

    UIView.animate(
      withDuration: duration,
      delay: delay,
      options: options,
      animations: {
        self.animateDismissal(window)
      },
      completion: { [weak self, weak window] _ in
        Task { @MainActor in
          guard let self, let window else { return }
          guard currentAnimationToken == self.animationToken else { return }
          window.isHidden = true
          self.resetWindowAfterDismissal(window)
          self.isDismissing = false
          completion?()
        }
      })
  }

  func resetWindowBeforePresentation(_ window: UIWindow) {}

  func willStartDismissal(_ window: UIWindow) {}

  func animateDismissal(_ window: UIWindow) {}

  func resetWindowAfterDismissal(_ window: UIWindow) {}

  // MARK: Private

  private let duration: TimeInterval
  private let delay: TimeInterval
  private let options: UIView.AnimationOptions
  private var isDismissing = false
  private var animationToken = 0
}

// MARK: - LoginWindowDismissalAnimator

@MainActor
final class LoginWindowDismissalAnimator: OverlayWindowAnimator {

  // MARK: Lifecycle

  init(duration: TimeInterval) {
    super.init(duration: duration)
  }

  // MARK: Internal

  override func resetWindowBeforePresentation(_ window: UIWindow) {
    window.transform = .identity
  }

  override func willStartDismissal(_ window: UIWindow) {
    window.endEditing(true)
  }

  override func animateDismissal(_ window: UIWindow) {
    window.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
  }

  override func resetWindowAfterDismissal(_ window: UIWindow) {
    window.transform = .identity
  }
}

// MARK: - PrivacyWindowDismissalAnimator

@MainActor
final class PrivacyWindowDismissalAnimator: OverlayWindowAnimator {

  // MARK: Lifecycle

  init(duration: TimeInterval) {
    super.init(duration: duration)
  }

  // MARK: Internal

  override func resetWindowBeforePresentation(_ window: UIWindow) {
    window.alpha = 1
  }

  override func animateDismissal(_ window: UIWindow) {
    window.alpha = 0
  }

  override func resetWindowAfterDismissal(_ window: UIWindow) {
    window.alpha = 1
  }
}
