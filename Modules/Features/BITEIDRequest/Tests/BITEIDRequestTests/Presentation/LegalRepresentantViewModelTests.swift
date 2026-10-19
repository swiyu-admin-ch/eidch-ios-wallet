// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
class LegalRepresentantViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    let context = EIDRequestContext()
    self.context = context
    Container.shared.eidRequestContext.register { @MainActor in context }

    viewModel = LegalRepresentantViewModel()
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
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
