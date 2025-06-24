import XCTest

extension XCUIElement {
  func forceTapElement() {
    if isHittable {
      tap()
    } else {
      // sometimes the view is hidden by another element (e.g. keyboard), so let's try to tap it by its coordinates
      let coordinate: XCUICoordinate = coordinate(withNormalizedOffset: CGVector.zero)
      coordinate.tap()
    }
  }

  func scrollDownToElement(app: XCUIApplication, maxScolls: Int = 10) {
    var count = 0
    while !isHittable && count < maxScolls {
      app.swipeUp()
      count += 1
    }
  }
}
