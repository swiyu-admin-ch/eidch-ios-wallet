import Foundation

// MARK: - AppCoordinator.State

extension AppCoordinator {
  enum State: Equatable {
    case splashScreen
    case onboarding
    case noDevicePin
    case wallet(WalletState)

    var isWallet: Bool {
      if case .wallet = self {
        return true
      }
      return false
    }
  }

  struct WalletState: Equatable {
    var isUnlocked: Bool
    var isReadyForDeeplinks: Bool
  }

  enum StartupEvent: Equatable {
    case splashScreenCompleted
    case onboardingCompleted
    case noDevicePinCompleted
  }

  enum LifecyclePhaseEvent: Equatable {
    case appWillEnterForeground
    case appDidBecomeActive
    case appWillResignActive
    case appDidEnterBackground
  }

  enum WalletEvent: Equatable {
    case homeDidAppear
    case userInactivityTimeout
    case logoutRequested
    case loginDidClose
  }

  enum DeeplinkEvent: Equatable {
    case deeplinkReceived(URL)
    case pendingDeeplinkNavigated(URL)
  }

  enum OverlayEvent: Equatable {
    case permissionAlertPresented
    case permissionAlertFinished
  }
}
