import BITAppAuth
import BITCore
import BITHome
import Factory
import Foundation
import NavigatorUI
import Testing
import UIKit
@testable import swiyu

// swiftlint:disable all

// MARK: - AppCoordinatorTests

@MainActor
@Suite
final class AppCoordinatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let hasDevicePinUseCase = HasDevicePinUseCaseProtocolSpy()
    let userSession = SessionSpy()
    let overlayWindowCoordinator = OverlayWindowCoordinatorSpy()
    self.hasDevicePinUseCase = hasDevicePinUseCase
    self.userSession = userSession
    self.overlayWindowCoordinator = overlayWindowCoordinator
    Container.shared.hasDevicePinUseCase.register { hasDevicePinUseCase }
    Container.shared.userSession.register { userSession }
    Container.shared.overlayWindowCoordinator.register { overlayWindowCoordinator }
    coordinator = AppCoordinator()
  }

  deinit {
    UserDefaults.standard.removeObject(forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)
    Container.shared.reset()
  }

  // MARK: Internal

  @Test
  func receiveDeepLinkWhenUserIsLoggedInMakesURLAvailableForNavigation() {
    makeCoordinatorInWalletState(isLoggedIn: true)
    handle(.homeDidAppear)

    handle(.deeplinkReceived(credentialOfferURL))

    #expect(coordinator.pendingDeeplinkURL == credentialOfferURL)

    handle(.pendingDeeplinkNavigated(credentialOfferURL))

    #expect(coordinator.pendingDeeplinkURL == nil)
  }

  @Test
  func receiveDeepLinkBeforeLoginWaitsForLoginCloseBeforeReplay() {
    makeCoordinatorInWalletState(isLoggedIn: false)
    handle(.homeDidAppear)

    handle(.deeplinkReceived(credentialOfferURL))
    userSession.isLoggedIn = true

    #expect(coordinator.pendingDeeplinkURL == nil)
    #expect(coordinator.state == .wallet(.init(isUnlocked: false, isReadyForDeeplinks: true)))

    handle(.loginDidClose)

    #expect(coordinator.pendingDeeplinkURL == credentialOfferURL)
    #expect(coordinator.state == .wallet(.init(isUnlocked: true, isReadyForDeeplinks: true)))

    handle(.pendingDeeplinkNavigated(credentialOfferURL))

    #expect(coordinator.pendingDeeplinkURL == nil)
  }

  @Test
  func splashScreenCompletedTransitionsToLockedWalletAndPresentsLoginWhenSessionLocked() {
    hasDevicePinUseCase.callAsFunctionReturnValue = true
    userSession.isLoggedIn = false
    UserDefaults.standard.set(false, forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)

    handle(.splashScreenCompleted)

    #expect(coordinator.state == .wallet(.init(isUnlocked: false, isReadyForDeeplinks: false)))
    #expect(overlayWindowCoordinator.presentLoginWindowCallsCount == 1)
  }

  @Test
  func receiveUnsupportedDeepLinkDoesNotStoreOrConsumeURL() throws {
    let url = try #require(URL(string: "https://mock.com"))
    makeCoordinatorInWalletState(isLoggedIn: false)
    handle(.homeDidAppear)

    handle(.deeplinkReceived(url))
    userSession.isLoggedIn = true
    handle(.loginDidClose)

    #expect(coordinator.pendingDeeplinkURL == nil)
  }

  @Test
  func receiveDeepLinkBeforeWalletWaitsForHomeToAppearBeforeReplay() {
    hasDevicePinUseCase.callAsFunctionReturnValue = true
    userSession.isLoggedIn = true
    UserDefaults.standard.set(false, forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)

    handle(.deeplinkReceived(credentialOfferURL))
    handle(.splashScreenCompleted)

    #expect(coordinator.pendingDeeplinkURL == nil)
    #expect(coordinator.state == .wallet(.init(isUnlocked: true, isReadyForDeeplinks: false)))

    handle(.homeDidAppear)

    #expect(coordinator.pendingDeeplinkURL == credentialOfferURL)

    handle(.pendingDeeplinkNavigated(credentialOfferURL))

    #expect(coordinator.pendingDeeplinkURL == nil)
  }

  @Test
  func loginCloseBeforeHomeAppearsDoesNotConsumePendingDeepLink() {
    hasDevicePinUseCase.callAsFunctionReturnValue = true
    userSession.isLoggedIn = true
    UserDefaults.standard.set(false, forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)

    handle(.deeplinkReceived(credentialOfferURL))
    handle(.splashScreenCompleted)
    handle(.loginDidClose)

    #expect(coordinator.pendingDeeplinkURL == nil)

    handle(.homeDidAppear)

    #expect(coordinator.pendingDeeplinkURL == credentialOfferURL)

    handle(.pendingDeeplinkNavigated(credentialOfferURL))

    #expect(coordinator.pendingDeeplinkURL == nil)
  }

  @Test
  func navigatedPendingDeeplinkDoesNotClearNewerPendingURL() throws {
    let oldURL = try #require(URL(string: "openid-credential-offer://?credential_offer=old"))
    let newURL = try #require(URL(string: "openid-credential-offer://?credential_offer=new"))
    makeCoordinatorInWalletState(isLoggedIn: true)
    handle(.homeDidAppear)

    handle(.deeplinkReceived(oldURL))
    handle(.deeplinkReceived(newURL))
    handle(.pendingDeeplinkNavigated(oldURL))

    #expect(coordinator.pendingDeeplinkURL == newURL)
  }

  @Test
  func userInactivityTimeoutOnSplashDoesNotRequireLogin() async {
    userSession.isLoggedIn = true

    await postUserInactivityTimeout()

    #expect(userSession.endSessionCallsCount == 0)
    #expect(overlayWindowCoordinator.presentLoginWindowCallsCount == 0)
  }

  @Test
  func userInactivityTimeoutOnOnboardingDoesNotRequireLogin() async {
    hasDevicePinUseCase.callAsFunctionReturnValue = true
    userSession.isLoggedIn = true
    UserDefaults.standard.set(true, forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)

    handle(.splashScreenCompleted)

    await postUserInactivityTimeout()

    #expect(userSession.endSessionCallsCount == 0)
    #expect(overlayWindowCoordinator.presentLoginWindowCallsCount == 0)
  }

  @Test
  func userInactivityTimeoutOnNoDevicePinDoesNotRequireLogin() async {
    hasDevicePinUseCase.callAsFunctionReturnValue = false
    userSession.isLoggedIn = true

    handle(.splashScreenCompleted)

    await postUserInactivityTimeout()

    #expect(userSession.endSessionCallsCount == 0)
    #expect(overlayWindowCoordinator.presentLoginWindowCallsCount == 0)
  }

  @Test
  func userInactivityTimeoutOnWalletRequiresLogin() async {
    makeCoordinatorInWalletState(isLoggedIn: true)

    await postUserInactivityTimeout()

    #expect(userSession.endSessionCallsCount == 1)
    #expect(overlayWindowCoordinator.presentLoginWindowCallsCount == 1)
    #expect(coordinator.state == .wallet(.init(isUnlocked: false, isReadyForDeeplinks: false)))
  }

  @Test
  func foregroundAfterBackgroundedWalletRequiresLoginWhenSessionExpired() {
    makeCoordinatorInWalletState(isLoggedIn: true)
    handle(.homeDidAppear)

    handle(.appDidEnterBackground)
    userSession.isLoggedIn = false
    handle(.appWillEnterForeground)

    #expect(userSession.endSessionCallsCount == 1)
    #expect(coordinator.state == .wallet(.init(isUnlocked: false, isReadyForDeeplinks: true)))
    #expect(overlayWindowCoordinator.presentPrivacyWindowCallsCount == 1)
    #expect(overlayWindowCoordinator.presentLoginWindowCallsCount == 1)
  }

  @Test
  func permissionAlertEventsForwardToOverlayCoordinator() {
    handle(.permissionAlertPresented)
    handle(.permissionAlertFinished)

    #expect(overlayWindowCoordinator.permissionAlertPresentedValues == [true, false])
  }

  // MARK: Private

  private let coordinator: AppCoordinator
  private let credentialOfferURL = URL(string: "openid-credential-offer://?credential_offer=mock")!
  private let hasDevicePinUseCase: HasDevicePinUseCaseProtocolSpy
  private let userSession: SessionSpy
  private let overlayWindowCoordinator: OverlayWindowCoordinatorSpy

  private func makeCoordinatorInWalletState(isLoggedIn: Bool) {
    hasDevicePinUseCase.callAsFunctionReturnValue = true
    userSession.isLoggedIn = isLoggedIn
    UserDefaults.standard.set(false, forKey: UserDefaultsKey.rootOnboardingIsEnabled.rawValue)

    handle(.splashScreenCompleted)
  }

  private func postUserInactivityTimeout() async {
    await Task.yield()
    let notificationObserver = NotificationCenter.default.notifications(named: .userInactivityTimeout).makeAsyncIterator()
    NotificationCenter.default.post(name: .userInactivityTimeout, object: nil)
    _ = await notificationObserver.next()
    await Task.yield()
  }

  private func handle(_ event: AppCoordinator.StartupEvent) {
    coordinator.handle(event)
  }

  private func handle(_ event: AppCoordinator.LifecyclePhaseEvent) {
    coordinator.handle(event)
  }

  private func handle(_ event: AppCoordinator.WalletEvent) {
    coordinator.handle(event)
  }

  private func handle(_ event: AppCoordinator.DeeplinkEvent) {
    coordinator.handle(event)
  }

  private func handle(_ event: AppCoordinator.OverlayEvent) {
    coordinator.handle(event)
  }

}

// MARK: - OverlayWindowCoordinatorSpy

private final class OverlayWindowCoordinatorSpy: OverlayWindowCoordinating {
  private(set) var presentLoginWindowCallsCount = 0
  private(set) var hideLoginWindowCallsCount = 0
  private(set) var presentPrivacyWindowCallsCount = 0
  private(set) var hidePrivacyWindowCallsCount = 0
  private(set) var permissionAlertPresentedValues = [Bool]()

  func attachMainWindow(_ window: UIWindow) {}

  func presentLoginWindow() {
    presentLoginWindowCallsCount += 1
  }

  func hideLoginWindow(onComplete: (() -> Void)?) {
    hideLoginWindowCallsCount += 1
    onComplete?()
  }

  func presentPrivacyWindow() {
    presentPrivacyWindowCallsCount += 1
  }

  func hidePrivacyWindow() {
    hidePrivacyWindowCallsCount += 1
  }

  func setPermissionAlertPresented(_ isPresented: Bool) {
    permissionAlertPresentedValues.append(isPresented)
  }
}

// swiftlint:enable implicitly_unwrapped_optional
