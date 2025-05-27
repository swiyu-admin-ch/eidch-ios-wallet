import Foundation
import XCTest
@testable import BITAppAuth

class LoginScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    loginButton = app.buttons[LoginView.AccessibilityIdentifier.loginButton.rawValue]
    pinField = app.secureTextFields[LoginView.AccessibilityIdentifier.pinField.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let loginButton: XCUIElement
  let pinField: XCUIElement

  func assertDisplayed() {
    XCTAssert(loginButton.waitForExistence(timeout: 5))
    XCTAssert(pinField.exists)
  }

  func login () {
    assertDisplayed()
    pinField.typeText("000000")
    loginButton.tap()
  }

}
