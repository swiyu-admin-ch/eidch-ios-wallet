import Foundation
import XCTest
@testable import BITAppAuth

class LoginScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    loginButton = app.buttons[LoginView.AccessibilityIdentifier.loginButton.rawValue]
    _ = loginButton.waitForExistence(timeout: .defaultTimeout)
    pinField = app.secureTextFields[LoginView.AccessibilityIdentifier.pinField.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let loginButton: XCUIElement
  let pinField: XCUIElement

  func assertDisplayed() {
    XCTAssert(loginButton.exists)
    XCTAssert(pinField.exists)
  }

  func login () {
    assertDisplayed()
    pinField.typeText("000000")
    loginButton.tap()
  }

}
