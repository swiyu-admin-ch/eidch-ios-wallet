import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

struct BiometricsScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> BiometricsScreen {
    let pin = "123456"
    return PinCodeConfirmationScreen.navigateToAfterLaunchingApp(app, pin: pin)
      .typePin(pin)
      .tapContinue()
      .assertBiometricsScreen()
  }

  @discardableResult
  func assertBiometricsScreen() -> BiometricsScreen {
    app.assertElementDisplayed(BiometricsView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapBack() -> PinCodeInformationScreen {
    app.tapNavigationBarBack()
    return PinCodeInformationScreen(app: app)
  }

}
