// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

class ClientAttestationErrorViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = ClientAttestationErrorViewModel(router: router)
  }

  @MainActor
  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.externalLinkCalled)
  }

  @MainActor
  func testSecondaryAction() {
    viewModel.secondaryAction()
    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testOpenHelp() {
    viewModel.openHelp()
    XCTAssertTrue(router.externalLinkCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: ClientAttestationErrorViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
