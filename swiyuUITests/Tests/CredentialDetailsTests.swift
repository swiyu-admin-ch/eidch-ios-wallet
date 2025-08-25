import Foundation
import XCTest
@testable import swiyuUITests_App

// MARK: - CredentialDetailsTests

final class CredentialDetailsTests: UITestCase {

  override var arguments: [String] {
    ["-disable-onboarding", "-pre-fill-database"]
  }

  func testBasicNavigation() {
    HomeScreen.navigateToAfterLaunchingApp(app)
      .assertHomeScreen()
      .assertCredentialsCountEquals(1)
      .tapCredential(index: 0)
      .assertCredentialDetailScreen()

      .tapWrongData()
      .assertCredentialDetailWrongDataScreen()
      .tapClose()
      .assertCredentialDetailScreen()

      .tapClose()
      .assertHomeScreen()
      .assertCredentialsCountEquals(1)
  }

  func testDeleteCredential() {
    HomeScreen.navigateToAfterLaunchingApp(app)
      .assertHomeScreen()
      .assertCredentialsCountEquals(1)
      .tapCredential(index: 0)
      .assertCredentialDetailScreen()

      .tapDelete()
      .assertDeleteAlertDisplayed(true)
      .tapCancelDelete()
      .assertDeleteAlertDisplayed(false)
      .tapDelete()
      .assertDeleteAlertDisplayed(true)
      .tapConfirmDelete()

      .assertHomeScreen()
      .assertCredentialsCountEquals(0)
  }
}
