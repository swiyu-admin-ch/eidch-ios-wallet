import Foundation
import XCTest
@testable import swiyuUITests_App

// MARK: - ReceiveTests

final class ReceiveLandscapeTests: XCTestCase {

  var app = XCUIApplication()

  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    app.launchArguments.append("-disable-onboarding")
    XCUIDevice.shared.orientation = .landscapeRight
    app.launch()
    XCTAssertTrue(XCUIDevice.shared.orientation.isLandscape)
  }

  override func tearDownWithError() throws {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    add(attachment)
  }

  func testBasicNavigationLandscape() {
    let receiveTests = ReceiveTests()
    receiveTests.testBottomAcceptButton()
  }

  func testDeclineOfferLandscape() throws {
    throw XCTSkip("Skipping this test until mocking strategy is reworked.")
    let receiveTests = ReceiveTests()
    try receiveTests.testBottomDeclineButton()
  }

  func testCancelDeclineOfferLandscape() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.bottomDeclineButton.tap()
    XCTAssert(credentialOfferScreen.confirmDeclineButton.waitForExistence(timeout: 3))
    credentialOfferScreen.cancelDeclineButton.tap()
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.bottomAcceptButton.tap()
    homeScreen.assertDisplayed()
  }

  func testCancelDeclineOfferMultipleTimesLandscape() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    for _ in 1...10 {
      credentialOfferScreen.bottomDeclineButton.tap()
      XCTAssert(credentialOfferScreen.confirmDeclineButton.waitForExistence(timeout: 3))
      credentialOfferScreen.cancelDeclineButton.tap()
      credentialOfferScreen.assertDisplayed()
    }
    credentialOfferScreen.bottomAcceptButton.tap()
    homeScreen.assertDisplayed()
  }

  func testCheckIssuerInformationLandscape() {
    let receiveTests = ReceiveTests()
    receiveTests.testCheckIssuerInformation()
  }

  func testCheckCredentialCardLandscape() {
    let receiveTests = ReceiveTests()
    receiveTests.testCheckCredentialCard()
  }

  func testCredentialHasDetailsLandscape() {
    let receiveTests = ReceiveTests()
    receiveTests.testCredentialHasDetails()
  }

  func testWrongDataButtonLandscape() {
    let receiveTests = ReceiveTests()
    receiveTests.testWrongDataButton()
  }

}
