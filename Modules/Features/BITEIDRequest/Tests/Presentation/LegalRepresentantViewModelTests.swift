// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
class LegalRepresentantViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = LegalRepresentantViewModel(router: router)
  }

  func testYesAction() {
    viewModel.action(true)

    XCTAssertTrue(router.documentSelectionCalled)
    XCTAssertEqual(router.context.hasLegalRepresentant, true)
  }

  func testNoAction() {
    viewModel.action(false)

    XCTAssertTrue(router.documentSelectionCalled)
    XCTAssertEqual(router.context.hasLegalRepresentant, false)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: LegalRepresentantViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
