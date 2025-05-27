import Foundation
import XCTest
@testable import BITTheming

class SecurityIntroductionScreen: InformationScreen {

  // MARK: Lifecycle

  override init(app: XCUIApplication) {
    backButton = app.buttons["Back"]
    tertiaryText = app.staticTexts[DefaultInformationContentView.AccessibilityIdentifier.tertiaryText.rawValue]
    super.init(app: app)
  }

  // MARK: Internal

  let backButton: XCUIElement
  let tertiaryText: XCUIElement
  let expectedImageLabel = "shield person"

  override func assertDisplayed() {
    super.assertDisplayed()
    XCTAssertEqual(getImagelabel(), expectedImageLabel)
    XCTAssertTrue(secondaryText.exists)
  }

  func navigateFromAppStartToScreen() {
    let welcomeScreen = WelcomeIntroductionScreen(app: app)
    welcomeScreen.assertDisplayed()
    welcomeScreen.primaryButton.tap()
    assertDisplayed()

  }

}
