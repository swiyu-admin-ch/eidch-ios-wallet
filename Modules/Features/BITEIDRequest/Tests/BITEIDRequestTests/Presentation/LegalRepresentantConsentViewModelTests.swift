// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
class LegalRepresentantConsentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    viewModel = LegalRepresentantConsentViewModel(caseId: caseId)
  }

  func testObtainConsent() {
    viewModel.obtainConsent()
    XCTAssertEqual(viewModel.destination, .legalRepresentantQRCode(caseId: caseId))
  }

  func testContinueAsParent() {
    viewModel.continueAsParent()
    XCTAssertEqual(viewModel.destination, .legalRepresentantVerification(caseId: caseId))
  }

  // MARK: Private

  private let caseId = "caseId"
  private var viewModel: LegalRepresentantConsentViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
