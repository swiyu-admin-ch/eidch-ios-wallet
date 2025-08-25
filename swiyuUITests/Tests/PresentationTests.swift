import XCTest

final class PresentationTests: UITestCase {

  override var arguments: [String] {
    ["-disable-onboarding", "-presentation"]
  }

  func testBasicNavigation() throws {
    throw XCTSkip("Skipping this test until mocking strategy is reworked.")
    HomeScreen.navigateToAfterLaunchingApp(app)
      .tapScanForPresentation()
      .assertPresentationRequestReviewScreen()
      .tapAccept()
      .assertPresentationRequestResultStateScreen()
      .assertSuccess()
      .tapClose()
      .assertHomeScreen()
  }
}
