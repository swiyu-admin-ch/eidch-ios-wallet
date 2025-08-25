import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

struct PrivacyPermissionScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> PrivacyPermissionScreen {
    CredentialIntroductionScreen.navigateToAfterLaunchingApp(app)
      .tapContinue()
      .assertPrivacyPermissionScreen()
  }

  @discardableResult
  func assertPrivacyPermissionScreen() -> PrivacyPermissionScreen {
    app.assertElementDisplayed(PrivacyPermissionView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapBack() -> CredentialIntroductionScreen {
    app.tapNavigationBarBack()
    return CredentialIntroductionScreen(app: app)
  }

  func tapAccept() -> PinCodeInformationScreen {
    app.tap(DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue)
    return PinCodeInformationScreen(app: app)
  }

  func tapDecline() -> PinCodeInformationScreen {
    app.tap(DefaultInformationFooterView.AccessibilityIdentifier.secondaryButton.rawValue)
    return PinCodeInformationScreen(app: app)
  }

}
