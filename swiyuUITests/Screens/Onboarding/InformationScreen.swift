import Foundation
import SwiftUI
import XCTest
@testable import BITTheming

class InformationScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    primaryButton = app.buttons[DefaultInformationFooterView.AccessibilityIdentifier.primaryButton.rawValue]
    secondaryButton = app.buttons[DefaultInformationFooterView.AccessibilityIdentifier.secondaryButton.rawValue]
    image = app.images[InformationView<DefaultInformationContentView, DefaultInformationFooterView>.AccessibilityIdentifier.image.rawValue]
    primaryText = app.staticTexts[DefaultInformationContentView.AccessibilityIdentifier.primaryText.rawValue]
    secondaryText = app.staticTexts[DefaultInformationContentView.AccessibilityIdentifier.secondaryText.rawValue]
    tertiaryText = app.staticTexts[DefaultInformationContentView.AccessibilityIdentifier.tertiaryText.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let primaryButton: XCUIElement
  let secondaryButton: XCUIElement
  let image: XCUIElement
  let primaryText: XCUIElement
  let secondaryText: XCUIElement
  let tertiaryText: XCUIElement

  func assertDisplayed() {
    XCTAssertTrue(primaryText.waitForExistence(timeout: .defaultTimeout))
  }

}
