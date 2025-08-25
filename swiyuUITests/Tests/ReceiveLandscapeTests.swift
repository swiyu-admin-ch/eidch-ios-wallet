import Foundation
import XCTest
@testable import swiyuUITests_App

// MARK: - ReceiveTests

final class ReceiveLandscapeTests: UITestCase {

  override var arguments: [String] {
    ["-disable-onboarding", "-pre-fill-database"]
  }

  override var orientation: UIDeviceOrientation {
    .landscapeRight
  }

  func testBasicNavigationLandscape() {
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

  func testAcceptOfferLandscape() throws {
    let homeScreen = HomeScreen.navigateToAfterLaunchingApp(app)
    let credentialsCount = homeScreen.getCredentialsCount()
    homeScreen
      .tapScanForCredentialOffer()
      .assertCredentialOfferScreen()
      .tapAccept()
      .assertHomeScreen()
      .assertCredentialsCountEquals(credentialsCount + 1)
  }

  func testDeclineOfferLandscape() throws {
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

  func testCancelDeclineOfferMultipleTimesLandscape() {
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
