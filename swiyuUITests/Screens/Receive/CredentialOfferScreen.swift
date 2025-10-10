import Foundation
import XCTest
@testable import BITCredential
@testable import BITInvitation
@testable import BITTheming

struct CredentialOfferScreen: Screen {

  // MARK: Internal

  let app: XCUIApplication

  @discardableResult
  func assertCredentialOfferScreen() -> CredentialOfferScreen {
    app.assertElementDisplayed(CredentialOfferView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  @discardableResult
  func assertIssuerHeaderDisplayed() -> CredentialOfferScreen {
    let actorHeaderView = app.otherElements[ActorHeaderView.AccessibilityIdentifier.content.rawValue]
    let issuerImage = app.images[ActorHeaderView.AccessibilityIdentifier.image.rawValue]

    XCTAssertTrue(actorHeaderView.waitForExistence(timeout: .defaultTimeout))
    XCTAssertTrue(issuerImage.exists)
    return self
  }

  @discardableResult
  func assertCredentialCardDisplayed() -> CredentialOfferScreen {
    app.assertElementDisplayed(CredentialOfferView.AccessibilityIdentifier.card.rawValue)
    return self
  }

  @discardableResult
  func assertClaimsListDisplayed() -> CredentialOfferScreen {
    app.assertElementDisplayed(CredentialOfferView.AccessibilityIdentifier.claimsList.rawValue)
    return self
  }

  @discardableResult
  func assertConfirmDeclineDisplayed() -> CredentialOfferScreen {
    app.assertElementDisplayed(CredentialOfferView.AccessibilityIdentifier.confirmDeclineContent.rawValue)
    return self
  }

  func tapAccept() -> HomeScreen {
    app.tap(CredentialOfferView.AccessibilityIdentifier.acceptButton.rawValue)
    return HomeScreen(app: app)
  }

  func tapDecline() -> CredentialOfferScreen {
    app.tap(CredentialOfferView.AccessibilityIdentifier.declineButton.rawValue)
    return self
  }

  func scrollToWrongData() -> CredentialOfferScreen {
    let button = app.buttons[CredentialOfferView.AccessibilityIdentifier.wrongData.rawValue]
    scrollToElement(button)
    return self
  }

  func tapWrongData() -> CredentialOfferWrongDataScreen {
    app.tap(CredentialOfferView.AccessibilityIdentifier.wrongData.rawValue)
    return CredentialOfferWrongDataScreen(app: app)
  }

  func tapConfirmDecline() -> HomeScreen {
    app.tap(CredentialOfferView.AccessibilityIdentifier.confirmDeclineButton.rawValue)
    return HomeScreen(app: app)
  }

  func tapCancelDecline() -> CredentialOfferScreen {
    app.tap(CredentialOfferView.AccessibilityIdentifier.cancelDeclineButton.rawValue)
    return self
  }

  // MARK: Private

  private func scrollToElement(_ element: XCUIElement, direction: XCUIElement.ScrollDirection = .down) {
    let scrollView = app.scrollViews.element(boundBy: 0)
    scrollView.scrollToElement(element, direction: direction, velocity: .fast)
  }
}
