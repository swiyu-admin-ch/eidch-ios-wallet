import BITActivityDetail
import BITAnalytics
import BITAppAuth
import BITCore
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
    syncAppLanguageCodes()

    application.registerForRemoteNotifications()

    return true
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
  @Injected(\.appLanguageService) private var appLanguageService: AppLanguageServiceProtocol
  @Injected(\.unlockWalletUseCase) private var unlockWalletUseCase: UnlockWalletUseCaseProtocol
  @Injected(\.isAnalyticsEnabledUseCase) private var isAnalyticsEnabledUseCase: IsAnalyticsEnabledUseCaseProtocol
  @Injected(\.registerPinCodeUseCase) private var registerPinCodeUseCase: RegisterPinCodeUseCaseProtocol
  @Injected(\.resetLoginAttemptCounterUseCase) private var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol
}

extension AppDelegate {
  func setupAdditionalConfigurationsIfNeeded() {
    #if DEBUG
    if ProcessInfo().arguments.contains("-disable-onboarding") {
      try? registerPinCodeUseCase(pinCode: "000000")
      UserDefaults.standard.set(false, forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)
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
    guard UserDefaults.standard.bool(forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue) else { return }
    try? resetLoginAttemptCounterUseCase()
    try? unlockWalletUseCase()
  }

  private func configureUserDefaults() {
    UserDefaults.standard.register(defaults: [
      UserDefaultsKey.rootOnboardingIsEnabled.rawValue: true,
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
    guard isAnalyticsEnabledUseCase() else {
      return
    }

    let providers = [
      DynatraceProvider(),
    ]

    for provider in providers {
      analytics.register(provider)
    }

    Task {
      await analytics.applyUserPrivacyPolicy(true)
    }
  }

  private func configureOpenIDSchemes() {
    Container.shared.additionalPresentationSchemes.register { ["swiyu-verify"] }
    Container.shared.additionalCredentialOfferSchemes.register { ["swiyu"] }
  }

  private func syncAppLanguageCodes() {
    try? appLanguageService.syncAppLanguageCodes()
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
        case .offer(let credential):
          InvitationDestinations.offer(credential)
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
