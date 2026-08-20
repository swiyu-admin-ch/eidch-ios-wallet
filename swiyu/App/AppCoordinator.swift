import BITCore
import BITDeeplink
import Factory
import Foundation
import Observation
import UIKit

// MARK: - AppCoordinator

@MainActor
@Observable
final class AppCoordinator {

  // MARK: Lifecycle

  init() {
    registerNotificationListeners()
  }

  deinit {
    notificationTasks.forEach { $0.cancel() }
  }

  // MARK: Internal

  private(set) var state = State.splashScreen

  var pendingDeeplinkURL: URL? {
    guard let deeplinkURL, canReplayDeeplink(deeplinkURL) else { return nil }
    return deeplinkURL
  }

  func attachMainWindow(_ window: UIWindow) {
    overlayWindowCoordinator.attachMainWindow(window)
  }

  func handle(_ event: StartupEvent) {
    handleStartupEvent(event)
  }

  func handle(_ event: LifecyclePhaseEvent) {
    handleLifecyclePhaseEvent(event)
  }

  func handle(_ event: WalletEvent) {
    handleWalletEvent(event)
  }

  func handle(_ event: DeeplinkEvent) {
    handleDeeplinkEvent(event)
  }

  func handle(_ event: OverlayEvent) {
    handleOverlayEvent(event)
  }

  // MARK: Private

  private var deeplinkURL: URL?

  @ObservationIgnored @Injected(\.hasDevicePinUseCase) private var hasDevicePinUseCase
  @ObservationIgnored @Injected(\.deepLinkManager) private var deepLinkManager
  @ObservationIgnored @Injected(\.userSession) private var userSession
  @ObservationIgnored @Injected(\.overlayWindowCoordinator) private var overlayWindowCoordinator
  @ObservationIgnored @Injected(\.appLanguageService) private var appLanguageService: AppLanguageServiceProtocol
  @ObservationIgnored private var notificationTasks = [Task<Void, Never>]()

  // MARK: Event handling

  private func handleStartupEvent(_ event: StartupEvent) {
    switch event {
    case .splashScreenCompleted:
      advanceFromStartupGate()
    case .onboardingCompleted:
      enterWallet(isUnlocked: true)
      NotificationCenter.default.post(name: .didLogin, object: nil)
      NotificationCenter.default.post(name: .didLoginClose, object: nil)
    case .noDevicePinCompleted:
      advanceFromNoDevicePin()
    }
  }

  private func handleLifecyclePhaseEvent(_ event: LifecyclePhaseEvent) {
    switch event {
    case .appWillEnterForeground:
      handleAppWillEnterForeground()
    case .appDidBecomeActive:
      overlayWindowCoordinator.hidePrivacyWindow()
      try? appLanguageService.syncAppLanguageCodes()
    case .appWillResignActive:
      overlayWindowCoordinator.presentPrivacyWindow()
    case .appDidEnterBackground:
      handleAppDidEnterBackground()
    }
  }

  private func handleWalletEvent(_ event: WalletEvent) {
    switch event {
    case .homeDidAppear:
      updateWalletState { $0.isReadyForDeeplinks = true }
    case .logoutRequested,
         .userInactivityTimeout:
      guard state.isWallet else { return }
      requireLogin()
    case .loginDidClose:
      guard state.isWallet else { return }

      if userSession.isLoggedIn {
        unlockWallet()
      } else {
        lockWallet()
      }
    }
  }

  private func handleDeeplinkEvent(_ event: DeeplinkEvent) {
    switch event {
    case .deeplinkReceived(let url):
      handleDeeplink(url)
    case .pendingDeeplinkNavigated(let url):
      clearPendingDeeplinkIfNeeded(url)
    }
  }

  private func handleOverlayEvent(_ event: OverlayEvent) {
    switch event {
    case .permissionAlertPresented:
      overlayWindowCoordinator.setPermissionAlertPresented(true)
    case .permissionAlertFinished:
      overlayWindowCoordinator.setPermissionAlertPresented(false)
    }
  }

  // MARK: Startup

  private func advanceFromStartupGate() {
    guard hasDevicePinUseCase() else {
      setState(.noDevicePin)
      return
    }

    if UserDefaults.standard.bool(forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue) {
      setState(.onboarding)
      return
    }

    enterWallet(isUnlocked: userSession.isLoggedIn)
  }

  private func advanceFromNoDevicePin() {
    if UserDefaults.standard.bool(forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue) {
      setState(.onboarding)
      return
    }

    enterWallet(isUnlocked: userSession.isLoggedIn)
  }

  private func enterWallet(isUnlocked: Bool) {
    setState(.wallet(WalletState(isUnlocked: isUnlocked, isReadyForDeeplinks: false)))
  }

  private func handleAppWillEnterForeground() {
    overlayWindowCoordinator.hidePrivacyWindow()
    NotificationCenter.default.post(name: .willEnterForeground, object: nil)

    guard hasDevicePinUseCase() else {
      setState(.noDevicePin)
      return
    }

    if state.isWallet, !userSession.isLoggedIn {
      lockWallet()
    }
  }

  private func handleAppDidEnterBackground() {
    overlayWindowCoordinator.presentPrivacyWindow()
    NotificationCenter.default.post(name: .didEnterBackground, object: nil)

    guard state.isWallet, userSession.isLoggedIn else { return }
    userSession.endSession()
  }

  // MARK: Wallet

  private func requireLogin() {
    if userSession.isLoggedIn {
      userSession.endSession()
    }

    lockWallet()
  }

  private func lockWallet() {
    updateWalletState { $0.isUnlocked = false }
  }

  private func unlockWallet() {
    updateWalletState { $0.isUnlocked = true }
  }

  // MARK: Deeplinks

  private func handleDeeplink(_ url: URL) {
    guard canHandleDeeplink(url) else { return }

    deeplinkURL = url
  }

  private func canReplayDeeplink(_ url: URL) -> Bool {
    guard
      let walletState = state.walletState,
      walletState.isUnlocked,
      walletState.isReadyForDeeplinks,
      userSession.isLoggedIn,
      canHandleDeeplink(url)
    else {
      return false
    }

    return true
  }

  private func clearPendingDeeplinkIfNeeded(_ url: URL) {
    guard deeplinkURL == url else { return }
    deeplinkURL = nil
  }

  private func canHandleDeeplink(_ url: URL) -> Bool {
    (try? deepLinkManager.dispatchFirst(url)) != nil
  }

  // MARK: State

  private func setState(_ newState: State) {
    let oldState = state
    guard oldState != newState else { return }

    state = newState
    applyOverlayChanges(from: oldState, to: newState)
  }

  private func updateWalletState(_ update: (inout WalletState) -> Void) {
    guard case .wallet(var walletState) = state else { return }

    let oldState = state
    update(&walletState)
    let newState = State.wallet(walletState)
    guard oldState != newState else { return }

    state = newState
    applyOverlayChanges(from: oldState, to: newState)
  }

  private func applyOverlayChanges(from oldState: State, to newState: State) {
    switch (oldState.requiresLoginOverlay, newState.requiresLoginOverlay) {
    case (false, true):
      overlayWindowCoordinator.presentLoginWindow()
    case (true, false):
      overlayWindowCoordinator.hideLoginWindow()
    default:
      break
    }
  }

  // MARK: Notifications

  private func registerNotificationListeners() {
    observe(.userInactivityTimeout, event: .userInactivityTimeout)
    observe(.logout, event: .logoutRequested)
    observe(.didLoginClose, event: .loginDidClose)
    observe(.permissionAlertPresented, event: .permissionAlertPresented)
    observe(.permissionAlertFinished, event: .permissionAlertFinished)
  }

  private func observe(_ name: Notification.Name, event: WalletEvent) {
    notificationTasks.append(
      Task { [weak self] in
        for await _ in NotificationCenter.default.notifications(named: name) {
          self?.handle(event)
        }
      })
  }

  private func observe(_ name: Notification.Name, event: OverlayEvent) {
    notificationTasks.append(
      Task { [weak self] in
        for await _ in NotificationCenter.default.notifications(named: name) {
          self?.handle(event)
        }
      })
  }
}

extension AppCoordinator.State {
  fileprivate var walletState: AppCoordinator.WalletState? {
    guard case .wallet(let walletState) = self else { return nil }
    return walletState
  }

  fileprivate var requiresLoginOverlay: Bool {
    walletState?.isUnlocked == false
  }
}
