import Foundation
import XCTest
@testable import BITHome

struct HomeScreen: Screen {

  let app: XCUIApplication

  static func navigateToAfterLaunchingApp(_ app: XCUIApplication) -> HomeScreen {
    LoginScreen.navigateToAfterLaunchingApp(app)
      .typePin()
      .tapLogin()
      .assertHomeScreen()
  }

  @discardableResult
  func assertHomeScreen() -> HomeScreen {
    app.assertElementDisplayed(HomeView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  @discardableResult
  func assertCredentialsCountEquals(_ count: Int) -> HomeScreen {
    XCTAssertEqual(getCredentialsCount(), count)
    return self
  }

  func getCredentialsCount() -> Int {
    app.buttons.matching(identifier: HomeView.AccessibilityIdentifier.credential.rawValue).count
  }

  func tapScanForCredentialOffer() -> CredentialOfferScreen {
    app.tap(HomeView.AccessibilityIdentifier.scanButton.rawValue)
    return CredentialOfferScreen(app: app)
  }

  func tapScanForPresentation() -> PresentationRequestReviewScreen {
    app.tap(HomeView.AccessibilityIdentifier.scanButton.rawValue)
    return PresentationRequestReviewScreen(app: app)
  }

  func tapCredential(index: Int) -> CredentialDetailScreen {
    let credentialButton = app.buttons.matching(identifier: HomeView.AccessibilityIdentifier.credential.rawValue).element(boundBy: index)
    credentialButton.tap()
    return CredentialDetailScreen(app: app)
  }

}
