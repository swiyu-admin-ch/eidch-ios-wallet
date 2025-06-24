import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITOnboarding

class EnterPinScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    continueButton = app.buttons[PinCodeView.AccessibilityIdentifier.continueButton.rawValue]
    _ = continueButton.waitForExistence(timeout: .defaultTimeout)
    pinField = app.secureTextFields.firstMatch
    backButton = app.navigationBars.buttons.element(boundBy: 0)
    titleText = app.navigationBars.textFields.element(boundBy: 0)
  }

  // MARK: Internal

  let app: XCUIApplication
  let pinField: XCUIElement
  let backButton: XCUIElement
  let titleText: XCUIElement
  let continueButton: XCUIElement

  func assertDisplayed() {
    XCTAssertTrue(pinField.waitForExistence(timeout: .defaultTimeout))
    XCTAssertTrue(pinField.exists)
    XCTAssertTrue(continueButton.exists)
  }

  func enterPin(pin: String) {
    assertDisplayed()
    pinField.forceTapElement()
    pinField.typeText(pin)
    continueButton.tap()
  }

}
