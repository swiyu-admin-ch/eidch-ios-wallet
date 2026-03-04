
import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding
@testable import swiyu

// MARK: - OnboardingSceneTests

final class OnboardingSceneTests: XCTestCase {

  // MARK: Internal

  class MockOnboardingCompletion {
    weak var delegate: OnboardingDelegate?

    func done() {
      delegate?.didCompleteOnboarding()
    }
  }

  @MainActor
  override func setUp() {
    super.setUp()

    sceneManagerDelegate = SceneManagerDelegateSpy()
    hasDevicePinUseCase = HasDevicePinUseCaseProtocolSpy()

    scene = OnboardingScene(hasDevicePinUseCase: hasDevicePinUseCase)

    scene.delegate = sceneManagerDelegate
  }

  @MainActor
  func testHappyPath_completion() {
    let mock = MockOnboardingCompletion()
    mock.delegate = scene

    mock.done()

    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedCallsCount, 1)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.count, 1)
    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.contains(where: { $0.sceneManager == AppScene.self }))
  }

  @MainActor
  func testHappyPath_willEnterForeground() {
    hasDevicePinUseCase.executeReturnValue = true
    scene.willEnterForeground()

    XCTAssertFalse(sceneManagerDelegate.changeSceneToAnimatedCalled)
  }

  @MainActor
  func testNoDevicePinCode() {
    hasDevicePinUseCase.executeReturnValue = false
    scene.willEnterForeground()

    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedCalled)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedCallsCount, 1)
    XCTAssertEqual(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.count, 1)
    XCTAssertTrue(sceneManagerDelegate.changeSceneToAnimatedReceivedInvocations.contains(where: { $0.sceneManager == NoDevicePinCodeScene.self }))
  }

  // MARK: Private

  // swiftlint:disable all
  private var scene: OnboardingScene!
  private var sceneManagerDelegate: SceneManagerDelegateSpy!
  private var hasDevicePinUseCase: HasDevicePinUseCaseProtocolSpy!
  // swiftlint:enable all

}
