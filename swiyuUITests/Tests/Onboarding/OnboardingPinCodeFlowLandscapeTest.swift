import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

// MARK: - OnboardingTests

final class OnboardingPinCodeFlowLandscapeTest: UITestCase {

  override var arguments: [String] {
    ["-enable-onboarding"]
  }

  override var orientation: UIDeviceOrientation {
    .landscapeRight
  }

  func testShortPinCodeLandscape() {
    let pinEntryTest = OnboardingPinCodeFlowTest(app: app)
    pinEntryTest.testShortPinCode()
  }

  func testNonMatchingPinCodeLandscape() {
    let pinEntryTest = OnboardingPinCodeFlowTest(app: app)
    pinEntryTest.testNonMatchingPinCode()
  }

  func testLongPinCodeEntryLandscape() {
    let pinEntryTest = OnboardingPinCodeFlowTest(app: app)
    pinEntryTest.testLongPinCodeEntry()
  }

}
