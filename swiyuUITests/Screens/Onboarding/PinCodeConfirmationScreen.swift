import Foundation
import XCTest
@testable import BITOnboarding

struct PinCodeConfirmationScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication, pin: String) -> PinCodeConfirmationScreen {
    PinCodeScreen.navigateToAfterLaunchingApp(app)
      .typePin(pin)
      .tapContinue()
      .assertPinCodeConfirmationScreen()
  }

  @discardableResult
  func assertPinCodeConfirmationScreen() -> PinCodeConfirmationScreen {
    app.assertElementDisplayed(PinCodeConfirmationView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  @discardableResult
  func typePin(_ pin: String) -> PinCodeConfirmationScreen {
    let pinField = app.secureTextFields[PinCodeConfirmationView.AccessibilityIdentifier.pinField.rawValue]
    pinField.typeText(pin)
    return self
  }

  func tapContinue() -> BiometricsScreen {
    app.tap(PinCodeConfirmationView.AccessibilityIdentifier.continueButton.rawValue)
    return BiometricsScreen(app: app)
  }

  func tapContinueNavigatesToPinCodeInformationScreen() -> PinCodeInformationScreen {
    app.tap(PinCodeConfirmationView.AccessibilityIdentifier.continueButton.rawValue)
    return PinCodeInformationScreen(app: app)
  }

  @discardableResult
  func tapContinueShowsWrongPinError() -> PinCodeConfirmationScreen {
    app.tap(PinCodeConfirmationView.AccessibilityIdentifier.continueButton.rawValue)
    app.assertElementDisplayed(PinCodeConfirmationView.AccessibilityIdentifier.wrongPinError.rawValue)
    return self
  }

}
