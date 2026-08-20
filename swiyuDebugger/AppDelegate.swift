import BITCredentialShared
import Factory
import UIKit

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

  // MARK: Internal

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    setupAdditionalConfigurationsIfNeeded()
    registerEnvironmentValues()
    return true
  }

  // MARK: Private

  private func setupAdditionalConfigurationsIfNeeded() {
    try? Container.shared.registerPinCodeUseCase.resolve().callAsFunction(pinCode: "000000")
    Container.shared.additionalPresentationSchemes.register { [ "swiyu-verify" ] }
    Container.shared.additionalCredentialOfferSchemes.register { [ "swiyu" ] }
    Container.shared.credentialRepository.register { LocalCredentialRepository() }.singleton
    Container.shared.activityRepository.register { LocalActivityRepository() }
  }
}
