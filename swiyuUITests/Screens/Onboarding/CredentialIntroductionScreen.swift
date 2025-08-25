import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

struct CredentialIntroductionScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> CredentialIntroductionScreen {
    SecurityIntroductionScreen.navigateToAfterLaunchingApp(app)
      .tapContinue()
      .assertCredentialIntroductionScreen()
  }

  @discardableResult
  func assertCredentialIntroductionScreen() -> CredentialIntroductionScreen {
    app.assertElementDisplayed(CredentialIntroductionView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapBack() -> SecurityIntroductionScreen {
    app.tapNavigationBarBack()
    return SecurityIntroductionScreen(app: app)
  }

  func tapContinue() -> PrivacyPermissionScreen {
    app.tap(DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue)
    return PrivacyPermissionScreen(app: app)
  }

}
