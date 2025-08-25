import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

struct WelcomeIntroductionScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> WelcomeIntroductionScreen {
    WelcomeIntroductionScreen(app: app)
      .assertWelcomeIntroductionScreen()
  }

  @discardableResult
  func assertWelcomeIntroductionScreen() -> WelcomeIntroductionScreen {
    app.assertElementDisplayed(WelcomeIntroductionView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapStart() -> SecurityIntroductionScreen {
    app.tap(DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue)
    return SecurityIntroductionScreen(app: app)
  }

}
