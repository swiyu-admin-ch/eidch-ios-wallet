import BITAppAuth
import BITHome
import BITTheming
import Factory
import SwiftUI
import UIKit

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  // MARK: Internal

  var window: UIWindow?

  var permissionAlertPresented = false

  var deeplinkUrl: URL? {
    didSet {
      guard let deeplinkUrl else { return }

      currentScene.didReceiveDeeplink(url: deeplinkUrl)
    }
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    registerNotifications()
    guard let windowScene = scene as? UIWindowScene else { return }
    window = Window(windowScene: windowScene)

    changeScene(to: SplashScreenScene.self, animated: false)
    registerDeeplink(from: connectionOptions.urlContexts)
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    hidePrivacyOverlay()
    NotificationCenter.default.post(name: .willEnterForeground, object: nil)
    currentScene.willEnterForeground()
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    registerDeeplink(from: URLContexts)
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    hidePrivacyOverlay()
  }

  func sceneWillResignActive(_ scene: UIScene) {
    if permissionAlertPresented { return }
    guard let windowScene = scene as? UIWindowScene else { return }
    showPrivacyOverlay(on: windowScene)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    if let windowScene = scene as? UIWindowScene {
      showPrivacyOverlay(on: windowScene)
    }

    NotificationCenter.default.post(name: .didEnterBackground, object: nil)
    currentScene.didEnterBackground()
  }

  // MARK: Private

  private var currentScene: SceneManagerProtocol = SplashScreenScene()
  private var privacyOverlayWindow: UIWindow?

  private func registerNotifications() {
    NotificationCenter.default.addObserver(forName: .permissionAlertPresented, object: nil, queue: .main) { [weak self] _ in
      self?.permissionAlertPresented = true
    }

    NotificationCenter.default.addObserver(forName: .permissionAlertFinished, object: nil, queue: .main) { [weak self] _ in
      self?.permissionAlertPresented = false
    }

    NotificationCenter.default.addObserver(forName: .didLoginClose, object: nil, queue: .main) { [weak self] _ in
      self?.hidePrivacyOverlay()
    }
  }
}

// MARK: - Privacy Overlay

extension SceneDelegate {

  private func showPrivacyOverlay(on windowScene: UIWindowScene) {
    guard privacyOverlayWindow == nil else { return }

    let overlayWindow = UIWindow(windowScene: windowScene)
    overlayWindow.windowLevel = .alert + 1
    overlayWindow.rootViewController = UIHostingController(rootView: PrivacyOverlayView())
    overlayWindow.isHidden = false

    privacyOverlayWindow = overlayWindow
  }

  private func hidePrivacyOverlay() {
    privacyOverlayWindow?.isHidden = true
    privacyOverlayWindow = nil
  }
}

// MARK: SceneManagerDelegate

extension SceneDelegate: SceneManagerDelegate {

  // MARK: Internal

  func changeScene(to sceneManager: any SceneManagerProtocol.Type, animated: Bool) {
    let currentScene = currentScene
    // swiftlint: disable init_with_name
    var scene = sceneManager.init()
    // swiftlint: enable init_with_name
    scene.delegate = self
    self.currentScene = scene

    let viewController = scene.viewController()

    guard let window, window.rootViewController?.className != viewController.className else { return }

    if animated {
      UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
        self.apply(viewController: viewController, to: scene, deeplinkUrl: self.deeplinkUrl, previousScene: currentScene)
      }, completion: nil)
    } else {
      apply(viewController: viewController, to: scene, deeplinkUrl: deeplinkUrl, previousScene: currentScene)
    }
  }

  func didConsumeDeeplink() {
    deeplinkUrl = nil
  }

  // MARK: Private

  private func apply(viewController: UIViewController, to scene: any SceneManagerProtocol, deeplinkUrl: URL?, previousScene: any SceneManagerProtocol) {
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()

    scene.willPresentScene(from: previousScene)

    if let deeplinkUrl = self.deeplinkUrl {
      scene.didReceiveDeeplink(url: deeplinkUrl)
    }

    scene.didPresentScene(from: previousScene)
  }

}

// MARK: - Deeplink

extension SceneDelegate {

  private func registerDeeplink(from urlContexts: Set<UIOpenURLContext>) {
    guard let url = urlContexts.first?.url else { return }
    deeplinkUrl = url
  }

}
