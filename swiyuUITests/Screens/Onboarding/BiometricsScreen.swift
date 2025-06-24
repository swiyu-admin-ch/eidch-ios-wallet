import Foundation
import XCTest
@testable import BITOnboarding
@testable import BITTheming

class BiometricsScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    skipButton = app.buttons[DefaultInformationFooterView.AccessibilityIdentifier.secondaryButton.rawValue]
    _ = skipButton.waitForExistence(timeout: .defaultTimeout)
    settingsButton = app.buttons[DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue]
    backButton = app.navigationBars.buttons.element(boundBy: 0)
    primaryText = app.staticTexts[BiometricView.AccessibilityIdentifier.primaryText.rawValue]
    secondaryText = app.staticTexts[BiometricView.AccessibilityIdentifier.secondaryText.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let skipButton: XCUIElement
  let settingsButton: XCUIElement
  let backButton: XCUIElement
  let primaryText: XCUIElement
  let secondaryText: XCUIElement

  func assertDisplayed() {
    XCTAssertTrue(primaryText.exists)
  }

}
