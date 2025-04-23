import XCTest

final class PresentationTests: XCTestCase {

  var app = XCUIApplication()

  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    app.launchArguments.append("-disable-onboarding")
    app.launchArguments.append("-presentation")
    app.launch()
    XCUIDevice.shared.orientation = .portrait
    XCTAssertTrue(XCUIDevice.shared.orientation.isPortrait)
  }

  override func tearDownWithError() throws {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    add(attachment)
  }

  func testBasicNavigation() throws {
    throw XCTSkip("Skipping this test until mocking strategy is reworked.")
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let presentationScreen = PresentationRequestReviewScreen(app: app)
    presentationScreen.assertDisplayed()
    presentationScreen.acceptButton.tap()

    let presentationResultScreen = PresentationRequestResultStateViewScreen(app: app)
    presentationResultScreen.closeButton.tap()
    homeScreen.assertDisplayed()
  }
}
