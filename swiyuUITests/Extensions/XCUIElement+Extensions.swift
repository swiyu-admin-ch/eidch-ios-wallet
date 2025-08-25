import XCTest

extension XCUIElement {

  enum ScrollDirection {
    case up
    case down
  }

  func scrollToElement(_ element: XCUIElement, direction: ScrollDirection = .down, maxScrolls: Int = 10, velocity: XCUIGestureVelocity = .default) {
    var count = 0
    while !element.isHittable && count < maxScrolls {
      switch direction {
      case .up:
        swipeDown(velocity: velocity)
      case .down:
        swipeUp(velocity: velocity)
      }
      count += 1
    }
    XCTAssertTrue(count < maxScrolls, "Failed to scroll to element: \(element)")
  }

}
