import BITActivityDetail
import BITAnalytics
import BITAppAuth
import BITCredential
import BITEIDRequest
import BITInvitation
import BITNetworking
import BITOTP
import BITPresentation
import BITPushNotification
import BITSettings
import BITTheming
import Factory
import NavigatorUI
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
    registerViewProviders()

    return true
  }

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let pushDeviceToken = deviceToken.hexString

    Task {
      await pushDataSource.setPushToken(pushDeviceToken)
    }
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
    #warning("TODO: Implement in a follow-up ticket")
  }

  // MARK: Private

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.pushDataSource) private var pushDataSource: PushDataSourceProtocol
  @Injected(\.unlockWalletUseCase) private var unlockWalletUseCase: UnlockWalletUseCaseProtocol
  @Injected(\.registerPinCodeUseCase) private var registerPinCodeUseCase: RegisterPinCodeUseCaseProtocol
  @Injected(\.resetLoginAttemptCounterUseCase) private var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol
}

extension AppDelegate {
  func setupAdditionalConfigurationsIfNeeded() {
    #if DEBUG
    if ProcessInfo().arguments.contains("-disable-onboarding") {
      try? registerPinCodeUseCase.execute(pinCode: "000000")
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
    try? resetLoginAttemptCounterUseCase.execute()
    try? unlockWalletUseCase.execute()
  }

  private func configureUserDefaults() {
    UserDefaults.standard.register(defaults: [
      "rootOnboardingIsEnabled": true,
      "isBiometricUsageAllowed": false,
      "eIDRequestAfterOnboardingEnabled": true,
      "otpEnabled": true,
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

    for provider in providers {
      analytics.register(provider)
    }
  }

  private func configureOpenIDSchemes() {
    Container.shared.additionalPresentationSchemes.register { ["swiyu-verify"] }
    Container.shared.additionalCredentialOfferSchemes.register { ["swiyu"] }
  }

  private func registerViewProviders() {
    Container.shared.activityExternalViewProvider.register {
      NavigationViewProvider {
        switch $0 {
        case .activityDetail(let activityId):
          ActivityDetailDestinations.activityDetail(activityId: activityId)
        case .settings:
          ActivityHistorySettingsView(showNavigationBar: true)
        }
      }
    }

    Container.shared.otpExternalViewProvider.register {
      NavigationViewProvider {
        switch $0 {
        case .eidRequest:
          EIDRequestDestinations.introduction
        }
      }
    }

    Container.shared.eIDRequestExternalViewProvider.register {
      NavigationViewProvider {
        switch $0 {
        case .presentation(let context):
          PresentationDestinations.start(context)
        }
      }
    }

    Container.shared.invitationExternalViewProvider.register {
      NavigationViewProvider {
        switch $0 {
        case .presentation(let context):
          PresentationDestinations.start(context)
        }
      }
    }

    Container.shared.homeExternalViewProvider.register {
      NavigationViewProvider {
        switch $0 {
        case .invitation(let tab):
          InvitationDestinations.scan(tab)
        case .deeplink(let url):
          InvitationDestinations.deeplink(url)
        case .offer(let credential, let trustInformation):
          InvitationDestinations.offer(credential, trustInformation)
        case .credentialDetail(let input):
          CredentialDestinations.detail(input)
        case .settings:
          SettingsDestinations.settings
        case .betaId:
          InvitationDestinations.betaId
        case .otp:
          OTPDestinations.intro
        case .eIDRequest:
          EIDRequestDestinations.introduction
        case .autoVerification(let caseId):
          EIDRequestDestinations.avWelcome(caseId: caseId)
        case .obtainConsent(let caseId):
          EIDRequestDestinations.legalRepresentantConsent(caseId: caseId)
        case .walletPairing(let caseId):
          EIDRequestDestinations.walletPairingList(caseId: caseId)
        case .identityCheck(let caseId):
          EIDRequestDestinations.avIdentityCheck(caseId: caseId)
        }
      }
    }
  }
}
