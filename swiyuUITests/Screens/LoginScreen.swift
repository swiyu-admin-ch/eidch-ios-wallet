import Foundation
import XCTest
@testable import BITAppAuth

struct LoginScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> LoginScreen {
    LoginScreen(app: app)
      .assertLoginScreen()
  }

  @discardableResult
  func assertLoginScreen() -> LoginScreen {
    app.assertElementDisplayed(LoginView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func typePin(_ pin: String = "000000") -> LoginScreen {
    let pinField = app.secureTextFields[LoginView.AccessibilityIdentifier.pinField.rawValue]
    pinField.typeText(pin)
    return self
  }

  func tapLogin() -> HomeScreen {
    app.tap(LoginView.AccessibilityIdentifier.loginButton.rawValue)
    return HomeScreen(app: app)
  }

}
