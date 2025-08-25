import Foundation
import SwiftUI
import XCTest
@testable import BITCredential
@testable import BITTheming

struct CredentialDetailWrongDataScreen: Screen {

  let app: XCUIApplication

  // MARK: Internal

  func assertCredentialDetailWrongDataScreen() -> CredentialDetailWrongDataScreen {
    app.assertElementDisplayed(CredentialDetailWrongDataView.AccessibilityIdentifier.content.rawValue)
    return self
  }

  func tapClose() -> CredentialDetailScreen {
    app.tap(CredentialDetailWrongDataView.AccessibilityIdentifier.closeButton.rawValue)
    return CredentialDetailScreen(app: app)
  }
}
