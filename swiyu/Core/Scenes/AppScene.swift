import BITAppAuth
import BITCore
import BITCredential
import BITDeeplink
import BITHome
import BITNavigation
import Factory
import Foundation
import NavigatorUI
import SwiftUI
import UIKit

// MARK: - AppScene

@MainActor
final class AppScene: SceneManagerProtocol {

  // MARK: Lifecycle

  init() {
    registerNotifications()
  }

  // MARK: Internal

  weak var delegate: (any SceneManagerDelegate)?

  func viewController() -> UIViewController {
    ManagedHostingController {
      HomeDestinations.home
        .navigationAutoReceive(HomeDestinations.self)
        .navigationRoot(self.navigator)
        .environment(\.font, .custom.body)
    }
  }

  func willPresentScene(from scene: any SceneManagerProtocol) {
    guard type(of: scene) != OnboardingScene.self else { return }
    router.login(animated: false)
  }

  func willEnterForeground() {
    guard hasDevicePinUseCase.execute() else {
      delegate?.changeScene(to: NoDevicePinCodeScene.self, animated: false)
      return
    }

    router.login(animated: false)
  }

  func didEnterBackground() {
    guard let topViewController = UIApplication.topViewController, !topViewController.className.contains("LoginHostingController") else {
      return
    }

    userSession.endSession()
  }

  func didReceiveDeeplink(url: URL) {
    guard userSession.isLoggedIn, canOpenUrl(url) else {
      return
    }

    let deeplinkManager = DeeplinkManager(allowedRoutes: RootDeeplinkRoute.allCases)
    guard (try? deeplinkManager.dispatchFirst(url)) != nil else { return }

    navigator.send(HomeDestinations.external(.deeplink(url)))
    delegate?.didConsumeDeeplink()
  }

  // MARK: Private

  @Injected(\.hasDevicePinUseCase) private var hasDevicePinUseCase
  @Injected(\.rootRouter) private var router
  @Injected(\.userSession) private var userSession: Session

  private let navigator = Navigator(configuration: NavigationConfiguration(verbosity: .info))

  private func registerNotifications() {
    NotificationCenter.default.addObserver(forName: .userInactivityTimeout, object: nil, queue: .main) { _ in
      Task { @MainActor [weak self] in
        self?.presentLogin()
      }
    }

    NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: .main) { _ in
      Task { @MainActor [weak self] in
        self?.presentLogin()
      }
    }

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

  private func canOpenUrl(_ url: URL) -> Bool {
    guard
      let topViewController = UIApplication.topViewController,
      !topViewController.className.contains("LoginHostingController")
    else {
      return false
    }

    return true
  }
}
