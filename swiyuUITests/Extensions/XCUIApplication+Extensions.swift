import XCTest

extension XCUIApplication {

  func tapNavigationBarBack() {
    let button = navigationBars.buttons.element(boundBy: 0)
    button.tap()
  }

  func assertElementDisplayed(_ identifier: String) {
    let content = descendants(matching: .any)[identifier]
    XCTAssertTrue(content.waitForExistence(timeout: .defaultTimeout))
  }

  func tap(_ identifier: String) {
    buttons[identifier].tap()
  }
}
