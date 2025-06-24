import Foundation
import XCTest
@testable import swiyuUITests_App

// MARK: - ReceiveTests

final class ReceiveTests: XCTestCase {

  var app = XCUIApplication()

  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    app.launchArguments.append("-disable-onboarding")
    XCUIDevice.shared.orientation = .portrait
    app.launch()
    XCTAssertTrue(XCUIDevice.shared.orientation.isPortrait)
  }

  override func tearDownWithError() throws {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    add(attachment)
  }

  func testBasicNavigation() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.acceptButton.forceTapElement()
    homeScreen.assertDisplayed()
  }

  func testDeclineOffer() throws {
    throw XCTSkip("Skipping this test until mocking strategy is reworked.")
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.declineButton.tap()
    XCTAssert(credentialOfferScreen.confirmDeclineButton.waitForExistence(timeout: .defaultTimeout))
    credentialOfferScreen.confirmDeclineButton.tap()
    homeScreen.assertDisplayed()
  }

  func testCancelDeclineOffer() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.declineButton.tap()
    XCTAssert(credentialOfferScreen.confirmDeclineButton.waitForExistence(timeout: .defaultTimeout))
    credentialOfferScreen.cancelDeclineButton.tap()
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.acceptButton.forceTapElement()
    homeScreen.assertDisplayed()
  }

  func testCancelDeclineOfferMultipleTimes() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    for _ in 1...10 {
      credentialOfferScreen.declineButton.tap()
      XCTAssert(credentialOfferScreen.confirmDeclineButton.waitForExistence(timeout: .defaultTimeout))
      credentialOfferScreen.cancelDeclineButton.tap()
      credentialOfferScreen.assertDisplayed()
    }
    credentialOfferScreen.acceptButton.forceTapElement()
    homeScreen.assertDisplayed()
  }

  func testCheckIssuerInformation() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.assertIssuerDisplayed()
  }

  func testCheckCredentialCard() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    XCTAssertTrue(credentialOfferScreen.card.exists)
  }

  func testCredentialHasDetails() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    XCTAssertTrue(credentialOfferScreen.offerDob.exists)
    XCTAssertTrue(credentialOfferScreen.offerFirstName.exists)
    XCTAssertTrue(credentialOfferScreen.offerLastName.exists)
  }

  func testWrongDataButton() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.wrongDataButton.tap()
    let credentialOfferWrongDataScreen = CredentialOfferWrongDataScreen(app: app)
    credentialOfferWrongDataScreen.assertDisplayed()
    credentialOfferWrongDataScreen.closeButton.tap()
    credentialOfferScreen.assertDisplayed()
  }

  func testBottomAcceptButton() {
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.bottomAcceptButton.scrollDownToElement(app: app)
    credentialOfferScreen.bottomAcceptButton.tap()
    homeScreen.assertDisplayed()
  }

  func testBottomDeclineButton() throws {
    throw XCTSkip("Skipping this test until mocking strategy is reworked.")
    let loginScreen = LoginScreen(app: app)
    loginScreen.login()

    let homeScreen = HomeScreen(app: app)
    homeScreen.assertDisplayed()
    homeScreen.scanButton.tap()

    let credentialOfferScreen = CredentialOfferScreen(app: app)
    credentialOfferScreen.assertDisplayed()
    credentialOfferScreen.bottomDeclineButton.tap()
    credentialOfferScreen.confirmDeclineButton.tap()
    homeScreen.assertDisplayed()
  }

}
