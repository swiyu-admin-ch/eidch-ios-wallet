import Foundation
import XCTest
@testable import BITOnboarding

struct PinCodeScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> PinCodeScreen {
    PinCodeInformationScreen.navigateToAfterLaunchingApp(app)
      .tapEnterPassword()
      .assertPinCodeScreen()
  }

  @discardableResult
  func assertPinCodeScreen() -> PinCodeScreen {
    app.assertElementDisplayed(PinCodeView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapBack() -> PinCodeInformationScreen {
    app.tapNavigationBarBack()
    return PinCodeInformationScreen(app: app)
  }

  @discardableResult
  func typePin(_ pin: String) -> PinCodeScreen {
    let pinField = app.secureTextFields[PinCodeView.AccessibilityIdentifier.pinField.rawValue]
    pinField.typeText(pin)
    return self
  }

  func tapContinue() -> PinCodeConfirmationScreen {
    app.tap(PinCodeView.AccessibilityIdentifier.continueButton.rawValue)
    return PinCodeConfirmationScreen(app: app)
  }

  @discardableResult
  func tapContinueShowsErrorMessage() -> PinCodeScreen {
    app.tap(PinCodeView.AccessibilityIdentifier.continueButton.rawValue)
    let message = app.staticTexts[PinCodeView.AccessibilityIdentifier.errorMessage.rawValue]
    XCTAssertTrue(message.waitForExistence(timeout: .defaultTimeout))
    return self
  }

}
