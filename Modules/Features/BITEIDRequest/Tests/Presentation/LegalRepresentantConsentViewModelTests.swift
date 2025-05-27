// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
class LegalRepresentantConsentViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = LegalRepresentantConsentViewModel(router: router, caseId: caseId)
  }

  func testObtainConsent() {
    viewModel.obtainConsent()
    XCTAssertEqual(router.legalRepresentantQRCodeArgument, caseId)
  }

  func testContinueAsParent() {
    viewModel.continueAsParent()
    XCTAssertTrue(router.closeCalled)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private let caseId = "caseId"
  private var router: MockEIDRequestRouter!
  private var viewModel: LegalRepresentantConsentViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
