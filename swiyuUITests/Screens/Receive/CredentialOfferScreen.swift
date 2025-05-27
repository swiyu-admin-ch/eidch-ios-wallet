import Foundation
import XCTest
@testable import BITCredential
@testable import BITInvitation
@testable import BITTheming

class CredentialOfferScreen: Screen {

  // MARK: Lifecycle

  init(app: XCUIApplication) {
    self.app = app
    acceptButton = app.buttons[CredentialOfferView.AccessibilityIdentifier.acceptButton.rawValue]
    declineButton = app.buttons[CredentialOfferView.AccessibilityIdentifier.declineButton.rawValue]
    card = app.images[CredentialOfferView.AccessibilityIdentifier.card.rawValue]
    issuer = app.staticTexts[ActorHeaderView.AccessibilityIdentifier.title.rawValue]
    issuerImage = app.images[ActorHeaderView.AccessibilityIdentifier.image.rawValue]
    verifiedStatus = app.staticTexts[ActorHeaderView.AccessibilityIdentifier.verifiedStatus.rawValue]
    confirmDeclineButton = app.buttons[CredentialOfferView.AccessibilityIdentifier.confirmDeclineButton.rawValue]
    cancelDeclineButton = app.buttons[CredentialOfferView.AccessibilityIdentifier.cancelDeclineButton.rawValue]
    offerPhoto = app.images["Photo"]
    offerDob = app.staticTexts["Date of birth"]
    offerFirstName = app.staticTexts["First name"]
    offerLastName = app.staticTexts["Last name"]
    wrongDataButton = app.buttons[IconKeyValueCell.AccessibilityIdentifier.button.rawValue]
    bottomAcceptButton = app.buttons[CredentialOfferView.AccessibilityIdentifier.bottomAcceptButton.rawValue]
    bottomDeclineButton = app.buttons[CredentialOfferView.AccessibilityIdentifier.bottomDeclineButton.rawValue]
  }

  // MARK: Internal

  let app: XCUIApplication
  let acceptButton: XCUIElement
  let declineButton: XCUIElement
  let card: XCUIElement
  let issuer: XCUIElement
  let verifiedStatus: XCUIElement
  let issuerImage: XCUIElement
  let confirmDeclineButton: XCUIElement
  let cancelDeclineButton: XCUIElement
  let offerPhoto: XCUIElement
  let wrongDataButton: XCUIElement
  let bottomAcceptButton: XCUIElement
  let bottomDeclineButton: XCUIElement
  let offerDob: XCUIElement
  let offerFirstName: XCUIElement
  let offerLastName: XCUIElement

  func assertDisplayed() {
    XCTAssert(issuer.waitForExistence(timeout: 5))
  }

  func assertIssuerDisplayed() {
    XCTAssertTrue(issuer.exists)
    XCTAssertTrue(issuerImage.exists)
    XCTAssertTrue(verifiedStatus.exists)
  }

}
