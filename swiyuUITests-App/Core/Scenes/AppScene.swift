import BITAppAuth
import BITCore
import BITTheming
import Factory
import Foundation
import UIKit

// MARK: - AppScene

@MainActor
final class AppScene: SceneManagerProtocol {

  // MARK: Lifecycle

  init() {
    router = Container.shared.rootRouter()
    registerNotifications()
  }

  init(router: RootRouterRoutes = Container.shared.rootRouter()) {
    self.router = router
    registerNotifications()
  }

  // MARK: Internal

  weak var delegate: (any SceneManagerDelegate)?

  func viewController() -> UIViewController {
    Container.shared.homeModule().viewController
  }

  func willPresentScene(from scene: any SceneManagerProtocol) {
    guard type(of: scene) != OnboardingScene.self else { return }
    router.login(animated: false)
  }

  func willEnterForeground() {
    router.login(animated: false)
  }

  func didEnterBackground() {
    guard let topViewController = UIApplication.topViewController, !topViewController.className.contains("LoginHostingController") else {
      return
    }

    userSession.endSession()
  }

  func didReceiveDeeplink(url: URL) {
    guard userSession.isLoggedIn, router.deeplink(url: url, animated: true) else {
      return
    }

    delegate?.didConsumeDeeplink()
  }

  // MARK: Private

  private var router: RootRouterRoutes
  @Injected(\.userSession) private var userSession: Session

  private func registerNotifications() {
    NotificationCenter.default.addObserver(forName: .didLoginClose, object: nil, queue: .main) { _ in
      Task { @MainActor in self.didReceiveLoginNotification() }
    }
  }

  private func presentLogin() {
    userSession.endSession()
    router.login(animated: true)
  }

  private func didReceiveLoginNotification() {
    guard
      let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
      let url = sceneDelegate.deeplinkUrl
    else { return }
    didReceiveDeeplink(url: url)
  }

}
