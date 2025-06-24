// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

class KeyAttestationErrorViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = KeyAttestationErrorViewModel(router: router)
  }

  @MainActor
  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testOpenHelp() {
    viewModel.openHelp()
    XCTAssertTrue(router.externalLinkCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: KeyAttestationErrorViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
