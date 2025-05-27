import Foundation
import XCTest
@testable import BITHome

class HomeScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    scanButton = app.buttons[HomeComposerView.AccessibilityIdentifier.scanButton.rawValue]
    menuButton = app.buttons[HomeComposerView.AccessibilityIdentifier.menuButton.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let scanButton: XCUIElement
  let menuButton: XCUIElement

  func assertDisplayed() {
    XCTAssert(scanButton.waitForExistence(timeout: 5))
    XCTAssert(menuButton.exists)
  }

}
