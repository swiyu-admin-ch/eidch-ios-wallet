import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

struct SecurityIntroductionScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> SecurityIntroductionScreen {
    WelcomeIntroductionScreen.navigateToAfterLaunchingApp(app)
      .tapStart()
      .assertSecurityIntroductionScreen()
  }

  @discardableResult
  func assertSecurityIntroductionScreen() -> SecurityIntroductionScreen {
    app.assertElementDisplayed(SecurityIntroductionView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapBack() -> WelcomeIntroductionScreen {
    app.tapNavigationBarBack()
    return WelcomeIntroductionScreen(app: app)
  }

  func tapContinue() -> CredentialIntroductionScreen {
    app.tap(DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue)
    return CredentialIntroductionScreen(app: app)
  }

}
