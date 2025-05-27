import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

class ConfirmPinScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    pinField = app.secureTextFields.firstMatch
    backButton = app.buttons["Back"]
    titleText = app.textFields["Confirm code (deepl)"]
    continueButton = app.buttons[PinCodeConfirmationView.AccessibilityIdentifier.continueButton.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let pinField: XCUIElement
  let backButton: XCUIElement
  let titleText: XCUIElement
  let continueButton: XCUIElement

  func assertDisplayed() {
    XCTAssertTrue(pinField.waitForExistence(timeout: 5))
    XCTAssertTrue(pinField.exists)
    XCTAssertTrue(continueButton.exists)
  }

  func enterPin(pin: String) {
    assertDisplayed()
    pinField.tap()
    pinField.typeText(pin)
    continueButton.tap()
  }

}
