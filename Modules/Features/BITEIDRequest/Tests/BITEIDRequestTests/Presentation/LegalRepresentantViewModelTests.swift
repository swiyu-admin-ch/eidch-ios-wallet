// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
class LegalRepresentantViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    context = EIDRequestContext()
    Container.shared.eidRequestContext.register { self.context }

    viewModel = LegalRepresentantViewModel()
  }

  func testYesAction() {
    viewModel.action(true)

    XCTAssertEqual(viewModel.destination, .documentSelection)
    XCTAssertEqual(context.hasLegalRepresentant, true)
  }

  func testNoAction() {
    viewModel.action(false)

    XCTAssertEqual(viewModel.destination, .documentSelection)
    XCTAssertEqual(context.hasLegalRepresentant, false)
  }

  // MARK: Private

  private var viewModel: LegalRepresentantViewModel!
  private var context: EIDRequestContext!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
