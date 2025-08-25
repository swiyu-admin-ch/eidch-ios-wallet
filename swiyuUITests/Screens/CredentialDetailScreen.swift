import Foundation
import XCTest
@testable import BITCredential

struct CredentialDetailScreen: Screen {

  let app: XCUIApplication

  @discardableResult
  func assertCredentialDetailScreen() -> CredentialDetailScreen {
    app.assertElementDisplayed(CredentialDetailView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  @discardableResult
  func assertDeleteAlertDisplayed(_ isDisplayed: Bool) -> CredentialDetailScreen {
    if isDisplayed {
      XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .defaultTimeout))
    } else {
      XCTAssertTrue(app.alerts.firstMatch.waitForNonExistence(timeout: .defaultTimeout))
    }
    return self
  }

  func tapClose() -> HomeScreen {
    app.tap(CredentialDetailView.AccessibilityIdentifier.closeButton.rawValue)
    return HomeScreen(app: app)
  }

  func tapDelete() -> CredentialDetailScreen {
    app.tap(CredentialDetailView.AccessibilityIdentifier.menuButton.rawValue)
    app.tap(CredentialDetailView.AccessibilityIdentifier.deleteButton.rawValue)
    return self
  }

  func tapCancelDelete() -> CredentialDetailScreen {
    app.alerts.firstMatch.buttons.element(boundBy: 0).tap()
    return self
  }

  func tapConfirmDelete() -> HomeScreen {
    app.alerts.firstMatch.buttons.element(boundBy: 1).tap()
    return HomeScreen(app: app)
  }

  func tapWrongData() -> CredentialDetailWrongDataScreen {
    app.tap(CredentialDetailView.AccessibilityIdentifier.menuButton.rawValue)
    app.tap(CredentialDetailView.AccessibilityIdentifier.wrongDataButton.rawValue)
    return CredentialDetailWrongDataScreen(app: app)
  }
}
