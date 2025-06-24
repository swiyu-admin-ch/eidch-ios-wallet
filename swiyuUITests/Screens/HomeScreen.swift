import Foundation
import XCTest
@testable import BITHome

class HomeScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    scanButton = app.buttons[HomeComposerView.AccessibilityIdentifier.scanButton.rawValue]
    _ = scanButton.waitForExistence(timeout: .defaultTimeout)
    menuButton = app.buttons[HomeComposerView.AccessibilityIdentifier.menuButton.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let scanButton: XCUIElement
  let menuButton: XCUIElement

  func assertDisplayed() {
    XCTAssert(scanButton.exists)
    XCTAssert(menuButton.exists)
  }

}
