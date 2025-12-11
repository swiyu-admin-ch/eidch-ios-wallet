import Factory
import SwiftUI

@MainActor
class LegalRepresentantConsentViewModel: ObservableObject {

  // MARK: Lifecycle

  init(caseId: String) {
    self.caseId = caseId
  }

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?

  func obtainConsent() {
    destination = .legalRepresentantQRCode(caseId: caseId)
  }

  func continueAsParent() {
    destination = .legalRepresentantVerification(caseId: caseId)
  }

  // MARK: Private

  private let caseId: String
}
