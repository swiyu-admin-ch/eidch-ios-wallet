import Foundation
import XCTest
@testable import BITOnboarding

class WelcomeIntroductionScreen: InformationScreen {

  // MARK: Lifecycle

  override init(app: XCUIApplication) {
    content = app.descendants(matching: .any)[WelcomeIntroductionView.AccessibilityIdentifier.welcomeIntroductionContent.rawValue]
    _ = content.waitForExistence(timeout: .defaultTimeout)
    super.init(app: app)
  }

  // MARK: Internal

  let content: XCUIElement

  override func assertDisplayed() {
    XCTAssertTrue(content.waitForExistence(timeout: .defaultTimeout))
    XCTAssertTrue(secondaryText.exists)
    super.assertDisplayed()
  }

  static func createAndNavigateFromAppStart(app: XCUIApplication) -> WelcomeIntroductionScreen {
    let currentScreen = WelcomeIntroductionScreen(app: app)
    currentScreen.assertDisplayed()
    return currentScreen
  }

}
