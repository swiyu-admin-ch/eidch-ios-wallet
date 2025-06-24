import Foundation
import XCTest
@testable import BITOnboarding

class SecurityIntroductionScreen: InformationScreen {

  // MARK: Lifecycle

  override init(app: XCUIApplication) {
    content = app.descendants(matching: .any)[SecurityIntroductionView.AccessibilityIdentifier.securityIntroductionContent.rawValue]
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

  static func createAndNavigateFromAppStart(app: XCUIApplication) -> SecurityIntroductionScreen {
    let welcomeScreen = WelcomeIntroductionScreen.createAndNavigateFromAppStart(app: app)
    welcomeScreen.primaryButton.tap()
    let currentScreen = SecurityIntroductionScreen(app: app)
    currentScreen.assertDisplayed()
    return currentScreen
  }

}
