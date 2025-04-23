import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

// MARK: - OnboardingTests

final class OnboardingLandscapeTests: XCTestCase {

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

  func testAppOpensOnStartScreenLandscape() {
    let onboardingTests = OnboardingTests()
    onboardingTests.testAppOpensOnStartScreen()
  }

  func testBasicNavigationLandscape() {
    let onboardingTests = OnboardingTests()
    onboardingTests.testBasicNavigation()
  }

  func testBacknavigationLandscape() {
    let onboardingTests = OnboardingTests()
    onboardingTests.testBacknavigation()
  }

  func testDynatraceDeclineNavigationLandscape() {
    let onboardingTests = OnboardingTests()
    onboardingTests.testDynatraceDeclineNavigation()
  }

  func testDynatraceAcceptThenDeclineNavigation() {
    let onboardingTests = OnboardingTests()
    onboardingTests.testDynatraceAcceptThenDeclineNavigation()
  }

}
