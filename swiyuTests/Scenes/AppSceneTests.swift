import Factory
import Foundation
import SwiftUI
import XCTest
@testable import BITAppAuth
@testable import swiyu

// swiftlint:disable force_unwrapping force_try implicitly_unwrapped_optional weak_delegate

final class AppSceneTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    sceneManagerDelegate = SceneManagerDelegateSpy()
    hasDevicePinUseCase = HasDevicePinUseCaseProtocolSpy()
    userSession = SessionSpy()
    router = RootRouterMock()

    Container.shared.hasDevicePinUseCase.register { self.hasDevicePinUseCase }
    Container.shared.userSession.register { self.userSession }
    Container.shared.rootRouter.register { self.router }

    appScene = AppScene()
    appScene.delegate = sceneManagerDelegate
  }

  @MainActor
  func testHappyPath() {
    hasDevicePinUseCase.executeReturnValue = true
    appScene.willEnterForeground()

    XCTAssertFalse(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertTrue(router.didCallLogin)
  }

  @MainActor
  func testViewControllerIsSwiftUIHostingController() {
    let viewController = appScene.viewController()

    XCTAssertTrue(viewController is UIHostingController<AnyView>)
  }

  @MainActor
  func testNoDevicePinCode() {
    hasDevicePinUseCase.executeReturnValue = false
    appScene.willEnterForeground()

    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedCallsCount, 1)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.count, 1)
    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.contains(where: { $0.sceneManager == NoDevicePinCodeScene.self }))
    XCTAssertFalse(router.didCallLogin)
  }

  @MainActor
  func testDidReceiveDeeplink_userLoggedIn_consumesLink() throws {
    userSession.isLoggedIn = true

    try appScene.didReceiveDeeplink(url: XCTUnwrap(URL(string: "openid-credential-offer://?credential_offer=mock")))

    XCTAssertTrue(sceneManagerDelegate.didConsumeDeeplinkCalled)
    XCTAssertEqual(sceneManagerDelegate.didConsumeDeeplinkCallsCount, 1)
    XCTAssertFalse(router.didCallDeeplink)
  }

  @MainActor
  func testDidReceiveDeeplink_userNotLoggedIn_doesNotConsumeLink() throws {
    userSession.isLoggedIn = false

    try appScene.didReceiveDeeplink(url: XCTUnwrap(URL(string: "openid-credential-offer://?credential_offer=mock")))

    XCTAssertFalse(sceneManagerDelegate.didConsumeDeeplinkCalled)
    XCTAssertFalse(router.didCallDeeplink)
  }

  @MainActor
  func testDidReceiveDeeplink_userLoggedInWithUnsupportedLink_doesNotConsumeLink() throws {
    userSession.isLoggedIn = true

    try appScene.didReceiveDeeplink(url: XCTUnwrap(URL(string: "https://mock.com")))

    XCTAssertFalse(sceneManagerDelegate.didConsumeDeeplinkCalled)
    XCTAssertFalse(router.didCallDeeplink)
  }

  func onUserInctivityDetected() {
    hasDevicePinUseCase.executeReturnValue = true

    NotificationCenter.default.post(name: .userInactivityTimeout, object: nil)

    XCTAssertFalse(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertTrue(router.didCallLogin)
  }

  // MARK: Private

  private var appScene: AppScene!
  private var router: RootRouterMock!
  private var sceneManagerDelegate: SceneManagerDelegateSpy!
  private var hasDevicePinUseCase: HasDevicePinUseCaseProtocolSpy!
  private var userSession: SessionSpy!
}
