// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

class AVWelcomeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = AVWelcomeViewModel(router: router)
  }

  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.walletPairingCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: AVWelcomeViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
