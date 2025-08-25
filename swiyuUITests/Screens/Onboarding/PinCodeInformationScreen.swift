import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

struct PinCodeInformationScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> PinCodeInformationScreen {
    PrivacyPermissionScreen.navigateToAfterLaunchingApp(app)
      .tapAccept()
      .assertPinCodeInformationScreen()
  }

  @discardableResult
  func assertPinCodeInformationScreen() -> PinCodeInformationScreen {
    app.assertElementDisplayed(PinCodeInformationView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapBack() -> PrivacyPermissionScreen {
    app.tapNavigationBarBack()
    return PrivacyPermissionScreen(app: app)
  }

  func tapEnterPassword() -> PinCodeScreen {
    app.tap(DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue)
    return PinCodeScreen(app: app)
  }

}
