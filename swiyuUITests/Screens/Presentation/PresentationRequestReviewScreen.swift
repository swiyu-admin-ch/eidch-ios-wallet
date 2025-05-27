import XCTest
@testable import BITPresentation

class PresentationRequestReviewScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    acceptButton = app.buttons[PresentationRequestReviewView.AccessibilityIdentifier.acceptButton.rawValue]
    declineButton = app.buttons[PresentationRequestReviewView.AccessibilityIdentifier.denyButton.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let acceptButton: XCUIElement
  let declineButton: XCUIElement

  func assertDisplayed() {
    XCTAssert(acceptButton.waitForExistence(timeout: 5))
    XCTAssert(declineButton.exists)
  }
}
