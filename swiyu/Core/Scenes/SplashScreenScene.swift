import BITAppAuth
import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - SplashScreenScene

@MainActor
final class SplashScreenScene: SceneManagerProtocol {

  // MARK: Internal

  weak var delegate: (any SceneManagerDelegate)?

  func viewController() -> UIViewController {
    let splashScreen = AnimatedSplashScreenHostingController()
    splashScreen.delegate = self
    return splashScreen
  }

  // MARK: Private

  @AppStorage("rootOnboardingIsEnabled") private var isOnboardingEnabled = true

  @Injected(\.hasDevicePinUseCase) private var hasDevicePinUseCase: HasDevicePinUseCaseProtocol
}

// MARK: SplashScreenDelegate

extension SplashScreenScene: SplashScreenDelegate {
  func didCompleteSplashScreen() {
    guard hasDevicePinUseCase.execute() else {
      delegate?.changeScene(to: NoDevicePinCodeScene.self, animated: false)
      return
    }

    guard !isOnboardingEnabled else {
      delegate?.changeScene(to: OnboardingScene.self, animated: false)
      return
    }

    delegate?.changeScene(to: AppScene.self)
  }
}
