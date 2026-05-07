import Factory
import SwiftUI

@MainActor
@Observable
class LegalRepresentantConsentViewModel {

  // MARK: Lifecycle

  init(caseId: String) {
    self.caseId = caseId
  }

  // MARK: Internal

  var destination: EIDRequestDestinations?

  func obtainConsent() {
    destination = .legalRepresentantQRCode(caseId: caseId)
  }

  func continueAsParent() {
    destination = .legalRepresentantVerification(caseId: caseId)
  }

  // MARK: Private

  private let caseId: String
}
