
import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding
@testable import swiyu

// MARK: - NoDevicePinCodeSceneTests

final class NoDevicePinCodeSceneTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()

    sceneManagerDelegate = SceneManagerDelegateSpy()
    hasDevicePinUseCase = HasDevicePinUseCaseProtocolSpy()

    Container.shared.noDevicePinCodeViewModel.register { _ in
      MockNoDevicePinCodeViewModel()
    }

    scene = NoDevicePinCodeScene(hasDevicePinUseCase: hasDevicePinUseCase)
    scene.delegate = sceneManagerDelegate
  }

  @MainActor
  func testAppSceneResult() {
    UserDefaults.standard.setValue(false, forKey: "rootOnboardingIsEnabled")

    (scene.module.viewModel as? MockNoDevicePinCodeViewModel)?.done()

    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedCallsCount, 1)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.count, 1)
    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.contains(where: { $0.sceneManager == AppScene.self }))
  }

  @MainActor
  func testOnBoardingResult() {
    UserDefaults.standard.setValue(true, forKey: "rootOnboardingIsEnabled")

    (scene.module.viewModel as? MockNoDevicePinCodeViewModel)?.done()

    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedCallsCount, 1)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.count, 1)
    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.contains(where: { $0.sceneManager == OnboardingScene.self }))
  }

  // MARK: Private

  // swiftlint:disable all
  private var scene: NoDevicePinCodeScene!
  private var sceneManagerDelegate: SceneManagerDelegateSpy!
  private var hasDevicePinUseCase: HasDevicePinUseCaseProtocolSpy!
  // swiftlint:enable all

}

// MARK: - MockNoDevicePinCodeViewModel

final class MockNoDevicePinCodeViewModel: NoDevicePinCodeViewModel {

  // MARK: Lifecycle

  init() {
    super.init(router: MockNoDevicePinRoutes())
  }

  // MARK: Internal

  func done() {
    delegate?.didCompleteNoDevicePinCode()
  }

}

// MARK: - MockNoDevicePinRoutes

final class MockNoDevicePinRoutes: NoDevicePinCodeRouterRoutes {

  func close(onComplete: (() -> Void)?) {}
  func close() {}
  func pop() {}
  func popToRoot() {}
  func dismiss() {}
  func pop(count: Int) {}

}
