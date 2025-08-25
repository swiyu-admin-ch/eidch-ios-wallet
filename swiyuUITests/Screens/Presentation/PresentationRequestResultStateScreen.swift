import XCTest
@testable import BITPresentation

struct PresentationRequestResultStateScreen: Screen {

  let app: XCUIApplication

  @discardableResult
  func assertPresentationRequestResultStateScreen() -> PresentationRequestResultStateScreen {
    app.assertElementDisplayed(PresentationRequestResultStateView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  @discardableResult
  func assertSuccess() -> PresentationRequestResultStateScreen {
    app.assertElementDisplayed(PresentationRequestResultStateView.AccessibilityIdentifier.successContent.rawValue)
    return self
  }

  func tapClose() -> HomeScreen {
    app.tap(PresentationRequestResultStateView.AccessibilityIdentifier.closeButton.rawValue)
    return HomeScreen(app: app)
  }
}
