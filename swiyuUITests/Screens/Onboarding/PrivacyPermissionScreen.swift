import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

class PrivacyPermissionScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    acceptButton = app.buttons[PrivacyPermissionView.AccessibilityIdentifier.acceptButton.rawValue]
    declineButton = app.buttons[PrivacyPermissionView.AccessibilityIdentifier.declineButton.rawValue]
    _ = declineButton.waitForExistence(timeout: .defaultTimeout)
    backButton = app.navigationBars.buttons.element(boundBy: 0)
    image = app.images[InformationView<DefaultInformationContentView, DefaultInformationFooterView>.AccessibilityIdentifier.image.rawValue]
    primaryText = app.staticTexts[PrivacyPermissionView.AccessibilityIdentifier.primaryText.rawValue]
    secondaryText = app.staticTexts[PrivacyPermissionView.AccessibilityIdentifier.secondaryText.rawValue]
    dataProtectionLink = app.links[PrivacyPermissionView.AccessibilityIdentifier.privacyLink.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let acceptButton: XCUIElement
  let declineButton: XCUIElement
  let backButton: XCUIElement
  let image: XCUIElement
  let primaryText: XCUIElement
  let secondaryText: XCUIElement
  let dataProtectionLink: XCUIElement
  let expectedImageLabel = "verify cross"

  static func createAndNavigateFromAppStart(app: XCUIApplication) -> PrivacyPermissionScreen {
    let credentialIntroduction = CredentialIntroductionScreen.createAndNavigateFromAppStart(app: app)
    credentialIntroduction.primaryButton.tap()
    let currentScreen = PrivacyPermissionScreen(app: app)
    currentScreen.assertDisplayed()
    return currentScreen
  }

  func assertDisplayed() {
    XCTAssertTrue(primaryText.exists)
  }

  func getImagelabel() -> String {
    app.descendants(matching: .image).matching(identifier: InformationView<DefaultInformationContentView, DefaultInformationFooterView>.AccessibilityIdentifier.image.rawValue).allElementsBoundByIndex[0].label
  }

}
