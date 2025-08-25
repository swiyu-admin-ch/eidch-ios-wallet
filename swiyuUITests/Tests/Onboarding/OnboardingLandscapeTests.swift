import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

// MARK: - OnboardingTests

final class OnboardingLandscapeTests: UITestCase {

  override var arguments: [String] {
    ["-enable-onboarding"]
  }

  override var orientation: UIDeviceOrientation {
    .landscapeRight
  }

  func testAppOpensOnStartScreenLandscape() {
    let onboardingTests = OnboardingTests(app: app)
    onboardingTests.testAppOpensOnStartScreen()
  }

  func testForwardAndBackwardNavigationLandscape() {
    let onboardingTests = OnboardingTests(app: app)
    onboardingTests.testForwardAndBackwardNavigation()
  }

  func testDynatraceAcceptThenDeclineNavigation() {
    let onboardingTests = OnboardingTests(app: app)
    onboardingTests.testDynatraceAcceptThenDeclineNavigation()
  }

}
