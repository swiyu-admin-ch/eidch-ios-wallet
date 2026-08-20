import BITAppAuth
import Factory
import SwiftUI
import UIKit

// MARK: - OverlayWindowCoordinating

@MainActor
protocol OverlayWindowCoordinating: AnyObject {
  func attachMainWindow(_ window: UIWindow)
  func presentLoginWindow()
  func hideLoginWindow(onComplete: (() -> Void)?)
  func presentPrivacyWindow()
  func hidePrivacyWindow()
  func setPermissionAlertPresented(_ isPresented: Bool)
}

extension OverlayWindowCoordinating {
  func hideLoginWindow() {
    hideLoginWindow(onComplete: nil)
  }
}

// MARK: - OverlayWindowCoordinator

@MainActor
final class OverlayWindowCoordinator: OverlayWindowCoordinating {

  // MARK: Lifecycle

  init(_ overlayWindowFactory: @escaping (UIWindow) -> UIWindow? = OverlayWindowCoordinator.makeOverlayWindow) {
    self.overlayWindowFactory = overlayWindowFactory
  }

  // MARK: Internal

  func attachMainWindow(_ window: UIWindow) {
    if mainWindow?.windowScene !== window.windowScene {
      resetLoginWindow()
      privacyWindow = nil
    }

    mainWindow = window
  }

  func presentLoginWindow() {
    let module = loginModule ?? makeLoginModule()
    guard let window = loginWindow ?? makeWindow(level: .alert + 1, usingVc: module.viewController) else {
      return
    }

    loginModule = module
    loginWindow = window
    loginWindowAnimator.prepareForPresentation(window)
    window.isHidden = false
    window.makeKeyAndVisible()
  }

  func hideLoginWindow(onComplete: (() -> Void)? = nil) {
    guard let loginWindow, !loginWindow.isHidden else {
      mainWindow?.makeKeyAndVisible()
      resetLoginWindow()
      onComplete?()
      return
    }

    loginWindowAnimator.dismiss(loginWindow) { [weak self] in
      self?.mainWindow?.makeKeyAndVisible()
      self?.resetLoginWindow()
      onComplete?()
    }
  }

  func presentPrivacyWindow() {
    guard !permissionAlertPresented else { return }

    guard let window = privacyWindow ?? makeWindow(level: .alert + 2, usingVc: UIHostingController(rootView: PrivacyOverlayView())) else {
      return
    }

    privacyWindow = window
    privacyWindowAnimator.prepareForPresentation(window)
    window.isHidden = false
  }

  func hidePrivacyWindow() {
    guard let privacyWindow, !privacyWindow.isHidden else { return }

    privacyWindowAnimator.dismiss(privacyWindow, completion: nil)
  }

  func setPermissionAlertPresented(_ isPresented: Bool) {
    permissionAlertPresented = isPresented
    if isPresented {
      hidePrivacyWindow()
    }
  }

  // MARK: Private

  private weak var mainWindow: UIWindow?
  private var loginWindow: UIWindow?
  private var loginModule: LoginModule?
  private var privacyWindow: UIWindow?
  private var permissionAlertPresented = false
  private let overlayWindowFactory: (UIWindow) -> UIWindow?

  @Injected(\.loginWindowAnimator) private var loginWindowAnimator
  @Injected(\.privacyWindowAnimator) private var privacyWindowAnimator

  private static func makeOverlayWindow(attachedTo mainWindow: UIWindow) -> UIWindow? {
    guard let windowScene = mainWindow.windowScene else {
      assertionFailure("Attached main window must belong to a window scene")
      return nil
    }

    return UIWindow(windowScene: windowScene)
  }

  private func makeLoginModule() -> LoginModule {
    let module = Container.shared.loginModule()
    module.configureForOverlayPresentation()
    return module
  }

  private func resetLoginWindow() {
    loginWindow = nil
    loginModule = nil
  }

  private func makeWindow(level: UIWindow.Level, usingVc viewController: UIViewController) -> UIWindow? {
    guard let window = makeDefaultWindow() else { return nil }

    window.windowLevel = level
    window.rootViewController = viewController
    return window
  }

  private func makeDefaultWindow() -> UIWindow? {
    guard let mainWindow else {
      assertionFailure("Main window must be attached before presenting overlay windows")
      return nil
    }

    return overlayWindowFactory(mainWindow)
  }

}
