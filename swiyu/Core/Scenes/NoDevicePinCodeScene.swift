import BITAppAuth
import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - NoDevicePinCodeScene

@MainActor
final class NoDevicePinCodeScene: SceneManagerProtocol {

  // MARK: Lifecycle

  init() {
    hasDevicePinUseCase = Container.shared.hasDevicePinUseCase()
    module.viewModel.delegate = self
  }

  init(hasDevicePinUseCase: HasDevicePinUseCaseProtocol = Container.shared.hasDevicePinUseCase()) {
    self.hasDevicePinUseCase = hasDevicePinUseCase
    module.viewModel.delegate = self
  }

  // MARK: Internal

  weak var delegate: (any SceneManagerDelegate)?

  var module: NoDevicePinCodeModule = Container.shared.noDevicePinCodeModule()

  func viewController() -> UIViewController {
    module.viewController
  }

  // MARK: Private

  @AppStorage("rootOnboardingIsEnabled") private var isOnboardingEnabled = true

  private var hasDevicePinUseCase: HasDevicePinUseCaseProtocol

}

// MARK: NoDevicePinCodeDelegate

extension NoDevicePinCodeScene: NoDevicePinCodeDelegate {

  func didCompleteNoDevicePinCode() {
    if isOnboardingEnabled {
      delegate?.changeScene(to: OnboardingScene.self, animated: false)
    } else {
      delegate?.changeScene(to: AppScene.self)
    }
  }

}
