import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

// MARK: - OnboardingTests

final class OnboardingTests: XCTestCase {

  var app = XCUIApplication()

  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    app.launchArguments.append("-enable-onboarding")
    XCUIDevice.shared.orientation = .portrait
    app.launch()
    XCTAssertTrue(XCUIDevice.shared.orientation.isPortrait)
  }

  override func tearDownWithError() throws {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    add(attachment)
  }

  func testAppOpensOnStartScreen() {
    let welcomeIntroductionScreen = WelcomeIntroductionScreen(app: app)
    welcomeIntroductionScreen.assertDisplayed()
  }

  func testBasicNavigation() {
    let welcomeIntroductionScreen = WelcomeIntroductionScreen(app: app)
    welcomeIntroductionScreen.assertDisplayed()
    welcomeIntroductionScreen.primaryButton.tap()

    let securityIntroductionScreen = SecurityIntroductionScreen(app: app)
    securityIntroductionScreen.assertDisplayed()
    securityIntroductionScreen.primaryButton.tap()

    let credentialIntroductionScreen = CredentialIntroductionScreen(app: app)
    credentialIntroductionScreen.assertDisplayed()
    credentialIntroductionScreen.primaryButton.tap()

    let privacyPermissionScreen = PrivacyPermissionScreen(app: app)
    privacyPermissionScreen.assertDisplayed()
  }

  func testBacknavigation() {
    let welcomeIntroductionScreen = WelcomeIntroductionScreen(app: app)
    welcomeIntroductionScreen.assertDisplayed()
    welcomeIntroductionScreen.primaryButton.tap()

    let securityIntroductionScreen = SecurityIntroductionScreen(app: app)
    securityIntroductionScreen.assertDisplayed()
    securityIntroductionScreen.primaryButton.tap()

    let credentialIntroductionScreen = CredentialIntroductionScreen(app: app)
    credentialIntroductionScreen.assertDisplayed()
    credentialIntroductionScreen.primaryButton.tap()

    let privacyPermissionScreen = PrivacyPermissionScreen(app: app)
    privacyPermissionScreen.assertDisplayed()
    privacyPermissionScreen.acceptButton.tap()

    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.assertDisplayed()
    pinCodeInformationScreen.backButton.tap()

    privacyPermissionScreen.assertDisplayed()
    privacyPermissionScreen.backButton.tap()

    credentialIntroductionScreen.assertDisplayed()
    credentialIntroductionScreen.backButton.tap()

    securityIntroductionScreen.assertDisplayed()
    securityIntroductionScreen.backButton.tap()

    welcomeIntroductionScreen.assertDisplayed()
  }

  func testPincodeEntry() {
    let welcomeIntroductionScreen = WelcomeIntroductionScreen(app: app)
    welcomeIntroductionScreen.assertDisplayed()
    welcomeIntroductionScreen.primaryButton.tap()

    let securityIntroductionScreen = SecurityIntroductionScreen(app: app)
    securityIntroductionScreen.assertDisplayed()
    securityIntroductionScreen.primaryButton.tap()

    let credentialIntroductionScreen = CredentialIntroductionScreen(app: app)
    credentialIntroductionScreen.assertDisplayed()
    credentialIntroductionScreen.primaryButton.tap()

    let privacyPermissionScreen = PrivacyPermissionScreen(app: app)
    privacyPermissionScreen.assertDisplayed()
    privacyPermissionScreen.acceptButton.tap()

    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.assertDisplayed()
    pinCodeInformationScreen.primaryButton.tap()

    let enterPinScreen = EnterPinScreen(app: app)
    XCTAssertTrue(enterPinScreen.pinField.waitForExistence(timeout: 5))

    enterPinScreen.enterPin(pin: "123456")
    XCTAssertTrue(enterPinScreen.pinField.waitForExistence(timeout: 5))
    enterPinScreen.enterPin(pin: "123456")

  }

  func testDynatraceDeclineNavigation() {
    let privacyPermissionScreen = PrivacyPermissionScreen(app: app)
    privacyPermissionScreen.navigateFromAppStartToScreen()
    privacyPermissionScreen.declineButton.tap()

    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.assertDisplayed()

  }

  func testDynatraceAcceptThenDeclineNavigation() {
    let welcomeIntroductionScreen = WelcomeIntroductionScreen(app: app)
    welcomeIntroductionScreen.assertDisplayed()
    welcomeIntroductionScreen.primaryButton.tap()

    let securityIntroductionScreen = SecurityIntroductionScreen(app: app)
    securityIntroductionScreen.assertDisplayed()
    securityIntroductionScreen.primaryButton.tap()

    let credentialIntroductionScreen = CredentialIntroductionScreen(app: app)
    credentialIntroductionScreen.assertDisplayed()
    credentialIntroductionScreen.primaryButton.tap()

    let privacyPermissionScreen = PrivacyPermissionScreen(app: app)
    privacyPermissionScreen.assertDisplayed()
    privacyPermissionScreen.declineButton.tap()

    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.assertDisplayed()
    pinCodeInformationScreen.backButton.tap()

    privacyPermissionScreen.assertDisplayed()
    privacyPermissionScreen.acceptButton.tap()

    pinCodeInformationScreen.assertDisplayed()
  }

}
