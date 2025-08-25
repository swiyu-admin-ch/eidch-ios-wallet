import XCTest
@testable import BITPresentation

struct PresentationRequestReviewScreen: Screen {

  let app: XCUIApplication

  // MARK: Internal

  @discardableResult
  func assertPresentationRequestReviewScreen() -> PresentationRequestReviewScreen {
    app.assertElementDisplayed(PresentationRequestReviewView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapAccept() -> PresentationRequestResultStateScreen {
    app.tap(PresentationRequestReviewView.AccessibilityIdentifier.acceptButton.rawValue)
    return PresentationRequestResultStateScreen(app: app)
  }
}
