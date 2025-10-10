import Foundation
import XCTest
@testable import swiyuUITests_App

// MARK: - ReceiveTests

final class ReceiveTests: UITestCase {

  override var arguments: [String] {
    ["-disable-onboarding", "-pre-fill-database"]
  }

  func testBasicNavigation() {
    HomeScreen.navigateToAfterLaunchingApp(app)
      .tapScanForCredentialOffer()
      .assertCredentialOfferScreen()
      .assertIssuerHeaderDisplayed()
      .assertCredentialCardDisplayed()
      .assertClaimsListDisplayed()
      .scrollToWrongData()
      .tapWrongData()
      .assertCredentialOfferWrongDataScreen()
      .tapClose()
      .assertCredentialOfferScreen()
      .tapAccept()
      .assertHomeScreen()
  }

  func testAcceptOffer() throws {
    let homeScreen = HomeScreen.navigateToAfterLaunchingApp(app)
    let credentialsCount = homeScreen.getCredentialsCount()
    homeScreen
      .tapScanForCredentialOffer()
      .assertCredentialOfferScreen()
      .tapAccept()
      .assertHomeScreen()
      .assertCredentialsCountEquals(credentialsCount + 1)
  }

  func testDeclineOffer() throws {
    let homeScreen = HomeScreen.navigateToAfterLaunchingApp(app)
    let credentialsCount = homeScreen.getCredentialsCount()
    homeScreen
      .tapScanForCredentialOffer()
      .assertCredentialOfferScreen()
      .tapDecline()
      .assertConfirmDeclineDisplayed()
      .assertIssuerHeaderDisplayed()
      .tapConfirmDecline()
      .assertHomeScreen()
      .assertCredentialsCountEquals(credentialsCount)
  }

  func testCancelDeclineOfferMultipleTimes() {
    let credentialOfferScreen = HomeScreen.navigateToAfterLaunchingApp(app)
      .tapScanForCredentialOffer()
      .assertCredentialOfferScreen()
    for _ in 1...5 {
      credentialOfferScreen
        .tapDecline()
        .assertConfirmDeclineDisplayed()
        .tapCancelDecline()
        .assertCredentialOfferScreen()
    }
    credentialOfferScreen
      .tapAccept()
      .assertHomeScreen()
  }
}
