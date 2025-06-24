import Foundation
import XCTest
@testable import BITOnboarding

class PinCodeInformationScreen: InformationScreen {

  // MARK: Lifecycle

  override init(app: XCUIApplication) {
    content = app.descendants(matching: .any)[PinCodeInformationView.AccessibilityIdentifier.pinCodeInformationContent.rawValue]
    _ = content.waitForExistence(timeout: .defaultTimeout)
    backButton = app.navigationBars.buttons.element(boundBy: 0)
    super.init(app: app)
  }

  // MARK: Internal

  let backButton: XCUIElement
  let content: XCUIElement

  override func assertDisplayed() {
    XCTAssertTrue(content.waitForExistence(timeout: .defaultTimeout))
    XCTAssertTrue(secondaryText.exists)
    super.assertDisplayed()
  }

  static func createAndNavigateFromAppStart(app: XCUIApplication) -> PinCodeInformationScreen {
    let credentialIntroduction = PrivacyPermissionScreen.createAndNavigateFromAppStart(app: app)
    credentialIntroduction.acceptButton.tap()
    let currentScreen = PinCodeInformationScreen(app: app)
    currentScreen.assertDisplayed()
    return currentScreen
  }

}
