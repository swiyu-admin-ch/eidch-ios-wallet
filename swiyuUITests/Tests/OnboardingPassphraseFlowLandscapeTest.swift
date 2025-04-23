import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

// MARK: - OnboardingTests

final class OnboardingPassphraseFlowLandscapeTest: XCTestCase {

  var app = XCUIApplication()

  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    app.launchArguments.append("-enable-onboarding")
    XCUIDevice.shared.orientation = .landscapeRight
    app.launch()
    XCTAssertTrue(XCUIDevice.shared.orientation.isLandscape)
  }

  override func tearDownWithError() throws {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    add(attachment)
  }

  func testPincodeEntryLandscape() {
    let pinEntryTest = OnboardingPassphraseFlowTest()
    pinEntryTest.testPincodeEntry()
  }

  func testShortPincodeLandscape() {
    let pinEntryTest = OnboardingPassphraseFlowTest()
    pinEntryTest.testShortPincode()
  }

  func testnonMatchingPincodeLandscape() {
    let pinEntryTest = OnboardingPassphraseFlowTest()
    pinEntryTest.testnonMatchingPincode()
  }

  func testLongPincodeEntryLandscape() {
    let pinEntryTest = OnboardingPassphraseFlowTest()
    pinEntryTest.testLongPincodeEntry()
  }

}
