import Alamofire
import BITAnalytics
import BITCredentialShared
import BITDataStore
import BITEntities
import BITTheming
import Factory
import RealmSwift
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
//    configureSslPinning()
    configureAnalyticsIfAllowed()

    setupAdditionalConfigurationsIfNeeded()
//    registerEnvironmentValues()

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
    if ProcessInfo().arguments.contains("-disable-onboarding") {
      try? Container.shared.registerPinCodeUseCase().execute(pinCode: "000000")
      UserDefaults.standard.set(false, forKey: "rootOnboardingIsEnabled")
    }
    if ProcessInfo().arguments.contains("-enable-onboarding") {
      UserDefaults.standard.set(true, forKey: "rootOnboardingIsEnabled")
    }
    // swiftlint: disable force_try
    if ProcessInfo().arguments.contains("-pre-fill-database") {
      let configuration = Container.shared.realmDataStoreConfiguration()
      let realm = try! Realm(configuration: configuration)
      try! realm.write {
        realm.deleteAll()
        realm.add(CredentialEntity(verifiableCredential: VerifiableCredential.Mock.sampleVC))
      }
    }
    // swiftlint: enable force_try
  }
}

extension AppDelegate {

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
    ])
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
}
