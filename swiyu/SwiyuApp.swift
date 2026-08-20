import BITAppAuth
import BITHome
import BITNavigation
import BITOnboarding
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - Application

@main
struct Application {
  static func main() {
    EventInterceptor.install()
    SwiyuApp.main()
  }
}

// MARK: - SwiyuApp

struct SwiyuApp: App {

  // MARK: Lifecycle

  init() {
    navigator = Navigator(configuration: NavigationConfiguration())
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      Group {
        switch coordinator.state {
        case .splashScreen:
          SplashScreenWrapper(onFinish: {
            coordinator.handle(.splashScreenCompleted)
          })
        case .onboarding:
          OnboardingModuleWrapper(onFinish: {
            coordinator.handle(.onboardingCompleted)
          })
        case .wallet:
          WalletRootView(coordinator: coordinator, navigator: navigator)
        case .noDevicePin:
          NoDevicePinCodeModuleWrapper(didReceiveDevicePinCode: {
            coordinator.handle(.noDevicePinCompleted)
          })
        }
      }
      .environment(\.font, .custom.body)
      .captureWindow { window in
        coordinator.attachMainWindow(window)
      }
      .onOpenURL { url in
        coordinator.handle(.deeplinkReceived(url))
      }
      .onChange(of: scenePhase) { _, newPhase in
        switch newPhase {
        case .active:
          coordinator.handle(.appWillEnterForeground)
          coordinator.handle(.appDidBecomeActive)
        case .inactive:
          coordinator.handle(.appWillResignActive)
        case .background:
          coordinator.handle(.appDidEnterBackground)
        @unknown default:
          break
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.scenePhase) private var scenePhase

  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @State private var coordinator = AppCoordinator()

  private let navigator: Navigator
}
