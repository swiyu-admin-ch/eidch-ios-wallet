import Foundation
import XCTest
@testable import BITCredential
@testable import BITInvitation
@testable import BITTheming

class CredentialOfferWrongDataScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    closeButton = app.buttons[CredentialOfferWrongDataView.AccessibilityIdentifier.closeButton.rawValue]
    image = app.images[InformationView<DefaultInformationContentView, DefaultInformationFooterView>.AccessibilityIdentifier.image.rawValue]
    primaryText = app.staticTexts[DefaultInformationContentView.AccessibilityIdentifier.primaryText.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let closeButton: XCUIElement
  let image: XCUIElement
  let primaryText: XCUIElement

  func assertDisplayed() {
    XCTAssert(image.waitForExistence(timeout: 3))
  }

}
