import Foundation
import XCTest
@testable import BITOnboarding

class CredentialIntroductionScreen: InformationScreen {

  // MARK: Lifecycle

  override init(app: XCUIApplication) {
    content = app.descendants(matching: .any)[CredentialIntroductionView.AccessibilityIdentifier.credentialIntroductionContent.rawValue]
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

  static func createAndNavigateFromAppStart(app: XCUIApplication) -> CredentialIntroductionScreen {
    let securityIntroduction = SecurityIntroductionScreen.createAndNavigateFromAppStart(app: app)
    securityIntroduction.primaryButton.tap()
    let currentScreen = CredentialIntroductionScreen(app: app)
    currentScreen.assertDisplayed()
    return currentScreen
  }

}
