import Alamofire
import BITAnalytics
import BITAppAuth
import BITCredential
import BITDataStore
import BITEIDRequest
import BITLocalAuthentication
import BITNetworking
import BITTheming
import Factory
import LocalAuthentication
import UIKit

// MARK: - AppDelegate

class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: Internal

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    BITAppearance.setup()

    configureUserDefaults()
    configureKeychain()
    configureSslPinning()
    configureAnalyticsIfAllowed()
    configureOpenIDSchemes()

    setupAdditionalConfigurationsIfNeeded()
    registerDefaultEnvironmentValues()
    registerEnvironmentValues()

    #if targetEnvironment (simulator)
    registerSimluatorEnvironmentValues()
    #endif

    return true
  }

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  // MARK: Private

  private let analytics = Container.shared.analytics()

}

extension AppDelegate {
  func setupAdditionalConfigurationsIfNeeded() {
    #if DEBUG
    if ProcessInfo().arguments.contains("-disable-onboarding") {
      try? Container.shared.registerPinCodeUseCase().execute(pinCode: "000000")
      UserDefaults.standard.set(false, forKey: "rootOnboardingIsEnabled")
    }
    #else
    // nothing
    #endif
  }
}

extension AppDelegate {

  // MARK: Internal

  func registerDefaultEnvironmentValues() {
    Container.shared.avBeamAppID.register { PlistFiles.avBeamAppID }
  }

  // MARK: Private

  private func configureKeychain() {
    guard UserDefaults.standard.bool(forKey: "rootOnboardingIsEnabled") else { return }
    try? Container.shared.resetLoginAttemptCounterUseCase().execute()
    try? Container.shared.unlockWalletUseCase().execute()
  }

  private func configureUserDefaults() {
    UserDefaults.standard.register(defaults: [
      "rootOnboardingIsEnabled": true,
      "isBiometricUsageAllowed": false,
      "eIDRequestAfterOnboardingEnabled": true,
      "isTranslationSwitchEnabled": false,
    ])
  }

  private func configureSslPinning() {
    NetworkContainer.shared.serverTrustManager.register {
      BITServerTrustManager()
    }
  }

  private func configureAnalyticsIfAllowed() {
    let providers = [
      DynatraceProvider(),
    ]

    let analytics = Container.shared.analytics()
    for provider in providers {
      analytics.register(provider)
    }
  }

  private func configureOpenIDSchemes() {
    Container.shared.additionalPresentationSchemes.register { [ "swiyu-verify" ] }
    Container.shared.additionalCredentialOfferSchemes.register { [ "swiyu" ] }
  }

  #if targetEnvironment (simulator)
  private func registerSimluatorEnvironmentValues() {
    Container.shared.submitEIDRequestUseCase.register { MockSubmitEIDRequestUseCase () }
    Container.shared.internalContext.register { FakeLAContext() }
  }
  #endif
}
