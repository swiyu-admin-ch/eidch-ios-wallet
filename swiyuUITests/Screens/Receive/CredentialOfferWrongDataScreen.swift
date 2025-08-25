import Foundation
import SwiftUI
import XCTest
@testable import BITCredential
@testable import BITInvitation
@testable import BITTheming

struct CredentialOfferWrongDataScreen: Screen {

  let app: XCUIApplication

  // MARK: Internal

  func assertCredentialOfferWrongDataScreen() -> CredentialOfferWrongDataScreen {
    app.assertElementDisplayed(CredentialOfferWrongDataView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapClose() -> CredentialOfferScreen {
    app.tap(CredentialOfferWrongDataView.AccessibilityIdentifier.closeButton.rawValue)
    return CredentialOfferScreen(app: app)
  }
}
