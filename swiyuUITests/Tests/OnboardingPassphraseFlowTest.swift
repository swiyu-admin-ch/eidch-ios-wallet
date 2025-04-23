import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

final class OnboardingPassphraseFlowTest: XCTestCase {

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

  func testPincodeEntry() {
    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.navigateFromAppStartToScreen()
    pinCodeInformationScreen.primaryButton.tap()

    let enterPinScreen = EnterPinScreen(app: app)
    enterPinScreen.enterPin(pin: "123456")
    let confirmPinScreen = ConfirmPinScreen(app: app)
    confirmPinScreen.enterPin(pin: "123456")

    let biometricScreen = BiometricsScreen(app: app)
    biometricScreen.assertDisplayed()
    biometricScreen.skipButton.tap()
  }

  func testShortPincode() {
    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.navigateFromAppStartToScreen()
    pinCodeInformationScreen.primaryButton.tap()

    let enterPinScreen = EnterPinScreen(app: app)
    enterPinScreen.enterPin(pin: "12345")
    enterPinScreen.assertDisplayed()
  }

  func testnonMatchingPincode() {
    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.navigateFromAppStartToScreen()
    pinCodeInformationScreen.primaryButton.tap()

    let enterPinScreen = EnterPinScreen(app: app)
    enterPinScreen.enterPin(pin: "123456")

    let confirmPinScreen = ConfirmPinScreen(app: app)
    confirmPinScreen.enterPin(pin: "1234567")
    confirmPinScreen.assertDisplayed()
  }

  func testLongPincodeEntry() {
    let longPassword = "QxM5dtwcQ51GOL54C9arEHsTl4b7^BQGQYPmA7C57^SMdsd34%FjBWB2fv^sLfIWmJ3!c!Rb27kqNzVbHqf5DlBRb&522Yhe74KqKIPIrtCh1PuUo3Xal0bE9Y@lrWaA"
    let pinCodeInformationScreen = PinCodeInformationScreen(app: app)
    pinCodeInformationScreen.navigateFromAppStartToScreen()
    pinCodeInformationScreen.primaryButton.tap()

    let enterPinScreen = EnterPinScreen(app: app)
    enterPinScreen.enterPin(pin: longPassword)

    let confirmPinScreen = ConfirmPinScreen(app: app)
    confirmPinScreen.enterPin(pin: longPassword)

    let biometricScreen = BiometricsScreen(app: app)
    biometricScreen.assertDisplayed()
    biometricScreen.skipButton.tap()

  }

}
